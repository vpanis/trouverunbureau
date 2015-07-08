module Payments
  module Mangopay
    class RefundPayinWorker
      include Sidekiq::Worker

      def perform(payout_id)
        init_log(payout_id)
        @payout = MangopayPayout.find_by_id(payout_id)
        return unless refund_possible?
        @booking = @payout.mangopay_payment.booking
        @venue = @booking.space.venue

        refund = mangopay_refund
        persist_data(refund)
      rescue MangoPay::ResponseError => e
        save_refund_error(e.message, e.code)
      end

      private

      def init_log(payout_id)
        str = "Payments::Mangopay::RefundPayingWorker on payout_id: #{payout_id}"
        Rails.logger.info(str)
      end

      def refund_possible?
        @payout.present? && @payout.mangopay_payment.present? &&
          @payout.mangopay_payment.payin_succeeded? && @payout.mangopay_payment.booking.present?
      end

      def save_refund_error(e, code, refund_id = nil)
        @payout.update_attributes(error_message: e.to_s, transaction_status: 'TRANSACTION_FAILED',
                                  error_code: code, transaction_id: refund_id)
      end

      def mangopay_refund
        currency = @venue.currency.upcase
        MangoPay::PayIn.refund(@booking.payment.transaction_id,
                               AuthorId: @booking.owner.mangopay_payment_account.mangopay_user_id,
                               DebitedFunds: {
                                 Currency: currency, Amount: @payout.amount * 100 },
                               Fees: { Currency: currency, Amount: 0 })
      end

      def save_refund(transaction)
        @payout.update_attributes(
          transaction_id: transaction['Id'],
          transaction_status: "TRANSACTION_#{transaction['Status']}")
      end

      def persist_data(refund)
        return save_refund_error(refund['ResultMessage'], refund['ResultCode'], refund['Id']) if
            refund['Status'] == 'FAILED'
        save_refund(refund)
      end
    end
  end
end
