module Payments
  module Mangopay
    class RefundPayinWorker
      include Sidekiq::Worker

      def perform(booking_id, user_id, payout_id)
        init_log(booking_id, user_id)
        @booking = Booking.includes(:payment).find_by_id(booking_id)
        @payout = MangopayPayout.find_by_id(payout_id)
        return unless refund_possible(user_id)
        @venue = @booking.space.venue

        refund = mangopay_refund
        persist_data(refund)
      rescue MangoPay::ResponseError => e
        save_refund_error(e.message, user_id)
      end

      private

      def init_log(booking_id, user_id, payout_id)
        str = "Payments::Mangopay::RefundPayingWorker on booking_id: #{booking_id}, "
        str += "user_id: #{user_id}, payout_id: #{payout_id}"
        Rails.logger.info(str)
      end

      def refund_possible?(user_id)
        @booking.present? && User.exists?(user_id) && @booking.payment.present? &&
          @booking.payment.payin_succeeded? && @payout.present?
      end

      def save_refund_error(e, user_id)
        @booking.payment.update_attributes(error_message: e.to_s,
                                           transaction_status: 'TRANSACTION_FAILED')
        BookingManager.change_booking_status(User.find(user_id), @booking,
                                             Booking.states[:error_refunding])
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
        @booking.payment.update_attributes(
          transaction_status: "TRANSACTION_#{transaction['Status']}")
        BookingManager.change_booking_status(User.find(user_id), @booking,
                                             Booking.states[:cancelled]) unless percentage == 0 &&
                                                                                deposit
      end

      def persist_data(refund)
        return save_refund_error(refund['ResultMessage']) if
            refund['Status'] == 'FAILED'
        save_refund(refund)
      end
    end
  end
end
