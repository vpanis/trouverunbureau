module Payments
  module Mangopay
    class TransferPaymentWorker
      include Sidekiq::Worker

      def perform(booking_id, percentage = 1, deposit = false)
        init_log(booking_id)
        @booking = Booking.find_by_id(booking_id)
        return unless transfer_possible?
        @venue = @booking.space.venue

        transfer = transfer_payment(price_calculator(percentage, deposit))
        return save_transfer_payment_error(transfer['ResultMessage']) if
          transfer['Status'] == 'FAILED'
        save_transfer_payment(transfer)
      rescue MangoPay::ResponseError => e
        save_transfer_payment_error(e.message)
      end

      private

      def init_log(booking_id)
        str = 'Payments::Mangopay::TransferPaymentWorker on '
        str += "booking_id: #{booking_id}, percentage: #{percentage}"
        Rails.logger.info(str)
      end

      def transfer_possible?
        @booking.present? && @booking.payment.present? && @booking.present.payin_succeeded?
      end

      def save_transfer_payment(transfer_payment)
        @booking.payment.update_attributes(
          transference_id: transfer_payment['Id'],
          transaction_status: "TRANSFER_#{transfer_payment['Status']}")
        # teorically, always, buy just in case
        Payments::Mangopay::PayoutPaymentWorker.perform_async(@booking.id, percentage) if
          transfer_payment['Status'] == 'SUCEEDED'
      end

      def save_transfer_payment_error(e)
        @booking.payment.update_attributes(error_message: e.to_s,
                                           status: 'TRANSFER_FAILED')
      end

      def transfer_payment(price)
        currency = @venue.currency.upcase
        # The fee will be charged in the payout
        MangoPay::Transfer.create(
          AuthorId: @booking.owner.mangopay_payment_account.mangopay_user_id,
          CreditedUserId: @venue.collection_account.mangopay_user_id,
          DebitedFunds: {
            Currency: currency, Amount: price },
          Fees: { Currency: currency, Amount: 0 },
          DebitedWalletID: @booking.owner.mangopay_payment_account.wallet_id,
          CreditedWalletID: @venue.collection_account.wallet_id)
      end

      def price_calculator(percentage, deposit)
        price = @booking.price * percentage
        price += @booking.deposit if deposit
        (price * 100).to_i
      end
    end
  end
end