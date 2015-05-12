module Payments
  module Mangopay
    class TransferPaymentWorker
      include Sidekiq::Worker

      def perform(booking_id, payout_id)
        init_log(booking_id)
        @booking = Booking.find_by_id(booking_id)
        @payout = MangopayPayout.find_by_id(payout_id)
        return unless transfer_possible?
        @venue = @booking.space.venue

        transfer = transfer_payment
        persist_data(transfer)
      rescue MangoPay::ResponseError => e
        save_transfer_payment_error(e.message)
      end

      private

      def init_log(booking_id, payout_id)
        str = 'Payments::Mangopay::TransferPaymentWorker on '
        str += "booking_id: #{booking_id}, payout_id: #{payout_id}"
        Rails.logger.info(str)
      end

      def transfer_possible?
        @booking.present? && @booking.payment.present? && @booking.payment.payin_succeeded? &&
          @payout.present?
      end

      def save_transfer_payment(transfer_payment)
        @payout.update_attributes(
          transference_id: transfer_payment['Id'],
          transaction_status: "TRANSFER_#{transfer_payment['Status']}")
        # teorically, always, buy just in case
        Payments::Mangopay::PayoutPaymentWorker.perform_async(@booking.id, @payout.id) if
          transfer_payment['Status'] == 'SUCEEDED'
      end

      def save_transfer_payment_error(e)
        @payout.update_attributes(error_message: e.to_s, status: 'TRANSFER_FAILED')
      end

      def transfer_payment
        currency = @venue.currency.upcase
        # The fee will be charged in the payout
        MangoPay::Transfer.create(
          AuthorId: @booking.owner.mangopay_payment_account.mangopay_user_id,
          CreditedUserId: @venue.collection_account.mangopay_user_id,
          DebitedFunds: {
            Currency: currency, Amount: @payout.amount * 100 },
          Fees: { Currency: currency, Amount: 0 },
          DebitedWalletID: @booking.owner.mangopay_payment_account.wallet_id,
          CreditedWalletID: @venue.collection_account.wallet_id)
      end

      def persist_data(transfer)
        return save_transfer_payment_error(transfer['ResultMessage']) if
          transfer['Status'] == 'FAILED'
        save_transfer_payment(transfer)
      end
    end
  end
end
