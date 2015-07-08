module Payments
  module Mangopay
    class PayoutPaymentWorker
      include Sidekiq::Worker

      def perform(payout_id)
        init_log(payout_id)
        @payout = MangopayPayout.find_by_id(payout_id)
        return unless payout_possible?
        transaction = pay_out
        persist_data(transaction)
      rescue MangoPay::ResponseError => e
        save_pay_out_error(e.message, e.code)
      end

      private

      def init_log(payout_id)
        str = "Payments::Mangopay::PayoutPaymentWorker on payout_id: #{payout_id}"
        Rails.logger.info(str)
      end

      def payout_possible?
        bool_acc = @payout.present? && @payout.mangopay_payment.present? &&
          @payout.mangopay_payment.payin_succeeded?
        @booking = @payout.mangopay_payment.booking
        bool_acc &&= @booking.present?
        @venue = @booking.space.venue
        bool_acc &&= @venue.collection_account.respond_to?(:accepted?) &&
          @venue.collection_account.accepted?
        bool_acc
      end

      def save_pay_out(transaction)
        @payout.update_attributes(
          transaction_id: transaction['Id'],
          transaction_status: "TRANSACTION_#{transaction['Status']}")
      end

      def save_pay_out_error(e, code, transaction_id = nil)
        @payout.update_attributes(error_message: e, status: 'TRANSACTION_FAILED',
                                  error_code: code, transaction_id: transaction_id)
      end

      def pay_out
        currency = @venue.currency.upcase
        # attribute BankWireRef, if we want to put some message in the bank account entry
        MangoPay::PayOut::BankWire.create(
          AuthorId: @venue.collection_account.mangopay_user_id,
          DebitedFunds: {
            Currency: currency, Amount: @payout.amount * 100 },
          Fees: { Currency: currency, Amount: @payout.fee  * 100 },
          DebitedWalletID: @venue.collection_account.wallet_id,
          BankAccountId: @venue.collection_account.bank_account_id)
      end

      def persist_data(transaction)
        return save_pay_out_error(transaction['ResultMessage'], transaction['ResultCode'],
                                  transaction['Id']) if transaction['Status'] == 'FAILED'
        save_pay_out(transaction)
      end
    end
  end
end
