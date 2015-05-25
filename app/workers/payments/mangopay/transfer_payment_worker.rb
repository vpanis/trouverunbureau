module Payments
  module Mangopay
    class TransferPaymentWorker
      include Sidekiq::Worker

      def perform(payout_id)
        init_log(payout_id)
        @payout = MangopayPayout.find_by_id(payout_id)
        return unless transfer_possible?
        transfer = transfer_payment
        persist_data(transfer)
      rescue MangoPay::ResponseError => e
        save_transfer_payment_error(e.message)
      end

      private

      def init_log(payout_id)
        str = "Payments::Mangopay::TransferPaymentWorker on payout_id: #{payout_id}"
        Rails.logger.info(str)
      end

      def transfer_possible?
        bool_acc = @payout.present? && @payout.mangopay_payment.present? &&
          @payout.mangopay_payment.payin_succeeded?
        @booking = @payout.mangopay_payment.booking
        bool_acc &&= @booking.present?
        @venue = @booking.space.venue
        bool_acc &&= @venue.collection_account.respond_to?(:accepted?) &&
          @venue.collection_account.accepted?
        bool_acc
      end

      def save_transfer_payment(transfer_payment)
        @payout.update_attributes(
          transference_id: transfer_payment['Id'],
          transaction_status: "TRANSFER_#{transfer_payment['Status']}")
        Payments::Mangopay::PayoutPaymentWorker.perform_async(@payout.id)
      end

      def save_transfer_payment_error(e, transference_id = nil)
        @payout.update_attributes(error_message: e.to_s, transaction_status: 'TRANSFER_FAILED',
                                  transference_id: transference_id)
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
        return save_transfer_payment_error(transfer['ResultMessage'], transfer['Id']) if
          transfer['Status'] == 'FAILED'
        save_transfer_payment(transfer)
      end
    end
  end
end
