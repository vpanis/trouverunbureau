module Payments
  module Mangopay
    class PayoutPaymentWorker
      include Sidekiq::Worker

      def perform(booking_id, percentage = 1)
        init_log(booking_id)
        @booking = Booking.find_by_id(booking_id)
        @venue = @booking.space.venue if @booking.present?
        return unless payout_possible?

        transaction = pay_out(percentage)
        persist_data(transaction)
      rescue MangoPay::ResponseError => e
        save_pay_out_error(e.message)
      end

      private

      def init_log(booking_id)
        str = 'Payments::Mangopay::PayoutPaymentWorker on '
        str += "booking_id: #{booking_id}, percentage: #{percentage}"
        Rails.logger.info(str)
      end

      def payout_possible?
        @booking.present? && @booking.payment.present? && @booking.payment.transfer_succeeded? &&
          @venue.collection_account.present? && @venue.collection_account.bank_account_id.present?
      end

      def save_pay_out(transaction)
        @booking.payment.update_attributes(
          payout_id: transaction['Id'],
          transaction_status: "PAYOUT_#{transaction['Status']}")
      end

      def save_pay_out_error(e)
        @booking.payment.update_attributes(error_message: e,
                                           status: 'PAYOUT_FAILED')
      end

      def pay_out(percentage)
        currency = @venue.currency.upcase
        # attribute BankWireRef, if we want to put some message in the bank account entry
        MangoPay::PayOut::BankWire.create(
          AuthorId: @venue.collection_account.mangopay_user_id,
          DebitedFunds: {
            Currency: currency, Amount: price_calculator(@booking.price, percentage) },
          Fees: { Currency: currency, Amount: price_calculator(@booking.fee, percentage) },
          DebitedWalletID: @venue.collection_account.wallet_id,
          BankAccountId: @venue.collection_account.bank_account_id)
      end

      def price_calculator(price, percentage)
        (price * percentage * 100).to_i
      end

      def persist_data(transaction)
        return save_pay_out_error(
          transaction['ResultCode'] + ': ' + transaction['ResultMessage']) if
            transaction['Status'] == 'FAILED'
        save_pay_out(transaction)
      end
    end
  end
end
