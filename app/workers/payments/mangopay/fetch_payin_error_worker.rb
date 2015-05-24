module Payments
  module Mangopay
    class FetchPayinErrorWorker
      include Sidekiq::Worker

      def perform(mangopay_payment_id)
        init_log(mangopay_payment_id)
        @mangopay_payment = MangopayPayment.find_by_id(mangopay_payment_id)
        return unless @mangopay_payment.present?

        transaction = fetch_transaction
        save_payment_error(transaction['ResultMessage']) if transaction['Status'] == 'FAILED'
      rescue MangoPay::ResponseError => e
        save_payment_error(e.message)
      end

      private

      def init_log(mangopay_payment_id)
        str = 'Payments::Mangopay::FetchPayinErrorWorker on '
        str += "mangopay_payment_id: #{mangopay_payment_id}"
        Rails.logger.info(str)
      end

      def save_payment_error(e)
        @mangopay_payment.update_attributes(error_message: e.to_s, status: 'PAYIN_FAILED')
      end

      def fetch_transaction
        MangoPay::PayIn.fetch(@mangopay_payment.transaction_id)
      end
    end
  end
end
