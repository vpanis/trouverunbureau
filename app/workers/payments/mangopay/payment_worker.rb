module Payments
  module Mangopay
    class PaymentWorker
      include Sidekiq::Worker

      def perform(booking_id, credit_card_id, user_id, return_url)
        init_log(booking_id, credit_card_id, user_id)
        @booking = Booking.includes(space: [:venue]).find_by_id(booking_id)
        # impossible, but...
        return unless require_validations?(user_id)
        @represented = @booking.owner
        @credit_card = MangopayCreditCard.find_by_id(credit_card_id)
        return unless valid_credit_card?

        payment = mangopay_transaction(@credit_card.credit_card_id, return_url)
        persist_data(payment, return_url)
      rescue MangoPay::ResponseError => e
        save_payment_error(e.message, e.code)
      end

      private

      def init_log(booking_id, credit_card_id, user_id)
        @user_id = user_id
        str = "Payments::Mangopay::PaymentWorker on booking_id: #{booking_id}, "
        str += "credit_card_id: #{credit_card_id}, user_id: #{user_id}"
        Rails.logger.info(str)
      end

      def valid_credit_card?
        if @credit_card.present? && @credit_card.created?
          verify_credit_card_first_payment
          true
        else
          save_payment_error('Credit card not available', 'credit_card_not_available')
          false
        end
      end

      def mangopay_transaction(credit_card, return_url)
        currency = @booking.space.venue.currency.upcase
        # The fee will be charged in the payout
        MangoPay::PayIn::Card::Direct.create(
          AuthorId: @booking.owner.mangopay_payment_account.mangopay_user_id,
          DebitedFunds: {
            Currency: currency, Amount: amount_price
          }, Fees: {
            Currency: currency, Amount: 0
          }, CreditedWalletId: @booking.owner.mangopay_payment_account.wallet_id,
          CardId: credit_card, SecureMode: @use_3d_secure_method,
          SecureModeReturnURL: absolute_return_url(return_url))
      end

      def save_payment(transaction_data, return_url)
        redirect = transaction_data['SecureModeRedirectURL'] || absolute_return_url(return_url)
        @booking.payment.update_attributes(
          transaction_id: transaction_data['Id'], error_message: nil,
          transaction_status: "PAYIN_#{transaction_data['Status']}", redirect_url: redirect,
          price_amount_in_wallet: @booking.price, deposit_amount_in_wallet: @booking.deposit,
          card_type: @credit_card.card_type, card_last_4: @credit_card.last_4,
          card_expiration_date: @credit_card.expiration,
          next_payout_at: @booking.from, mangopay_credit_card: @credit_card)
        fill_receipt
      end

      def save_payment_error(e, code)
        @booking.payment.update_attributes(error_message: e.to_s, error_code: code,
                                           transaction_status: 'PAYIN_FAILED')
        message = Message.create(m_type: Message.m_types[:payment_error], user_id: @user_id,
          represented: @booking.owner, booking_id: @booking.id, text: e.to_s)
        NewMessageService.new(message).send_notifications
        @booking.pending_payment!
      end

      def require_validations?(user_id)
        @booking.present? && @booking.owner.present? && User.exists?(user_id) &&
          @booking.payment.present?
      end

      def absolute_return_url(return_url)
        Rails.configuration.base_url + return_url
      end

      def persist_data(payment, return_url)
        return save_payment_error(payment['ResultMessage'], payment['ResultCode']) if
          payment['Status'] == 'FAILED'
        save_payment(payment, return_url)
      end

      def amount_price
        (@booking.price + @booking.deposit) * 100
      end

      def fill_receipt
        attributes = user_data if @represented.is_a?(User)
        attributes = organization_data if @represented.is_a?(Organization)
        Receipt.create(attributes)
      end

      def verify_credit_card_first_payment
        return @use_3d_secure_method = 'DEFAULT' if @credit_card.already_paid
        cc = MangoPay::Card.fetch(@credit_card.credit_card_id)
        return @use_3d_secure_method = 'FORCE' if
          cc['Country'].in?(MangopayCreditCard::EURO_COUNTRIES_3166_ALPHA_3)
        @use_3d_secure_method = 'DEFAULT'
      end

      def user_data
        { payment: @booking.payment, guest_first_name: @represented.first_name,
          guest_last_name: @represented.last_name, guest_location: @represented.location,
          guest_email: @represented.email, guest_phone: @represented.phone,
          guest_avatar: @represented.avatar }
      end

      def organization_data
        { payment: @booking.payment, guest_first_name: @represented.name,
          guest_email: @represented.email, guest_phone: @represented.phone,
          guest_avatar: @represented.logo }
      end
    end
  end
end
