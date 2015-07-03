module Payments
  module Mangopay
    class FetchPayoutErrorForHookWorker
      include Sidekiq::Worker

      def perform(transaction_id, date_i, retry_count, refund)
        init_log(transaction_id)
        @payout = MangopayPayout.find_by(transaction_id: transaction_id, p_type: p_type(refund))
        return retry_worker(transaction_id, date_i, retry_count, refund) unless
          @payout.present? && @payout.notification_date_int.to_i < date_i

        transaction = fetch_transaction(refund)
        save_payout_error(transaction['ResultMessage'], transaction['ResultCode'], date_i) if
          transaction['Status'] == 'FAILED'
      rescue MangoPay::ResponseError => e
        save_payout_error(e.message, e.code, date_i)
      end

      private

      def init_log(transaction_id)
        str = 'Payments::Mangopay::FetchPayoutErrorForHookWorker on '
        str += "payout_id: #{transaction_id}, #{ (refund) ? 'Refund' : 'Payout'}"
        Rails.logger.info(str)
      end

      def save_payout_error(e, code, date_i)
        @payout.update_attributes(error_message: e.to_s, transaction_status: 'TRANSACTION_FAILED',
                                  error_code: code, notification_date_int: date_i)
        BookingManager.change_booking_status(@payout.user, @payout.mangopay_payment.booking,
                                             Booking.states[:error_refunding]) if refund
        @payout.receipt.destroy if @payout.receipt.present?
      end

      def fetch_transaction(refund)
        return MangoPay::Refund.fetch(@payout.transaction_id) if refund
        MangoPay::PayOut.fetch(@payout.transaction_id)
      end

      def retry_worker(transaction_id, date_i, retry_count, refund)
        FetchPayoutErrorForHookWorker.perform_in((retry_count + 1).minutes, transaction_id, date_i,
                                                 retry_count + 1, refund) if
          retry_count < Rails.configuration.payment.notification_attempts
      end

      def p_type(refund)
        return MangopayPayout.p_types[:refund] if refund
        MangopayPayout.p_types[:payout_to_user]
      end
    end
  end
end
