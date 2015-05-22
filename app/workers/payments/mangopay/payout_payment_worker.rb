module Payments
  module Mangopay
    class PayoutPaymentWorker
      include Sidekiq::Worker

      def perform(booking_id, payout_id, user_id = nil)
        init_log(booking_id, payout_id)
        @user_id = user_id
        @booking = Booking.find_by_id(booking_id)
        @payout = MangopayPayout.find_by_id(payout_id)
        @venue = @booking.space.venue if @booking.present?
        return unless payout_possible?

        transaction = pay_out
        persist_data(transaction)
      rescue MangoPay::ResponseError => e
        save_pay_out_error(e.message)
      end

      private

      def init_log(booking_id, payout_id)
        str = 'Payments::Mangopay::PayoutPaymentWorker on '
        str += "booking_id: #{booking_id}, payout_id: #{payout_id}"
        Rails.logger.info(str)
      end

      def payout_possible?
        @booking.present? && @payout.present? && @payout.transfer_succeeded? &&
          @venue.collection_account.present? && @venue.collection_account.bank_account_id.present?
      end

      def save_pay_out(transaction)
        @payout.update_attributes(
          payout_id: transaction['Id'],
          transaction_status: "TRANSACTION_#{transaction['Status']}")
        BookingManager.change_booking_status(User.find(@user_id), @booking,
                                             Booking.states[:denied]) if
          @booking.state == 'refunding' && User.exists?(@user_id)
      end

      def save_pay_out_error(e)
        @payout.update_attributes(error_message: e, status: 'TRANSACTION_FAILED')
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
        return save_pay_out_error(
          transaction['ResultCode'] + ': ' + transaction['ResultMessage']) if
            transaction['Status'] == 'FAILED'
        save_pay_out(transaction)
      end
    end
  end
end
