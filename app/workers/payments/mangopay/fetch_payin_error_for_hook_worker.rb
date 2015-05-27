module Payments
  module Mangopay
    class FetchPayinErrorForHookWorker
      include Sidekiq::Worker

      def perform(transaction_id, date_i, retry_count)
        init_log(transaction_id)
        @mangopay_payment = MangopayPayment.find_by(transaction_id: transaction_id)
        return retry_worker(transaction_id, date_i, retry_count) unless
          @mangopay_payment.present? && @mangopay_payment.notification_date_int.to_i < date_i

        transaction = fetch_transaction
        save_payment_error(transaction['ResultMessage'], date_i) if
          transaction['Status'] == 'FAILED'
      rescue MangoPay::ResponseError => e
        save_payment_error(e.message, date_i)
      end

      private

      def init_log(transaction_id)
        str = 'Payments::Mangopay::FetchPayinErrorForHookWorker on '
        str += "transaction_id: #{transaction_id}"
        Rails.logger.info(str)
      end

      def save_payment_error(e, date_i)
        @mangopay_payment.update_attributes(
          error_message: e.to_s, notification_date_int: date_i,
          transaction_status: 'PAYIN_FAILED')
        BookingManager.change_booking_status(@mangopay_payment.user_paying,
                                             @mangopay_payment.booking,
                                             Booking.states[:pending_payment])
      end

      def fetch_transaction
        MangoPay::PayIn.fetch(@mangopay_payment.transaction_id)
      end

      def retry_worker(transaction_id, date_i, retry_count)
        FetchPayinErrorForHookWorker.perform_in((retry_count + 1).minutes, transaction_id, date_i,
                                                retry_count + 1) if
          retry_count < Rails.configuration.payment.notification_attempts
      end
    end
  end
end
