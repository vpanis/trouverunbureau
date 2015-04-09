module Payments
  module Mangopay
    class TransferPaymentWorker
      include Sidekiq::Worker

      def perform(booking_id)
        init_log(booking_id)
        @booking = Booking.find_by_id(booking_id)
        return unless transfer_possible?

        transfer = transfer_payment
        return save_transfer_payment_error(transfer_payment['ResultMessage']) if
          transfer_payment['Status'] == 'FAILED'
        save_transfer_payment(transfer_payment)
      rescue MangoPay::ResponseError => e
        save_transfer_payment_error(e.message)
      end

      private

      def init_log(booking_id)
        str = 'Payments::Mangopay::TransferPaymentWorker on '
        str += "booking_id: #{booking_id}"
        Rails.logger.info(str)
      end

      def transfer_possible?
        @booking.present? && @booking.payment.present? && @booking.present.payin_created?
      end

      def save_transfer_payment(transfer_payment)
        @booking.payment.update_attributes(
          transaction_status: "TRANSFER_#{transfer_payment['Status']}")
      end

      def save_transfer_payment_error(e)
        @booking.payment.update_attributes(error_message: e.to_s,
                                           status: 'TRANSFER_FAILED')
      end

      def transfer_payment
        currency = @venue.currency.upcase
        Mangopay::Transfer.create(
          AuthorId : @booking.owner.mangopay_payment_account.mangopay_user_id,
          CreditedUserId : @venue.collection_account.mangopay_user_id,
          DebitedFunds: { Currency : currency, Amount : @booking.price * 100 },
          Fees : { Currency : currency, Amount : @booking.fee * 100 },
          DebitedWalletID : @booking.owner.mangopay_payment_account.wallet_id,
          CreditedWalletID : @venue.collection_account.wallet_id)
      end
    end
  end
end
