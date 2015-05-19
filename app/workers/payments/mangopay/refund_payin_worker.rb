module Payments
  module Mangopay
    class RefundPayinWorker
      include Sidekiq::Worker

      def perform(booking_id, user_id, percentage = 1, deposit = false)
        init_log(booking_id, user_id)
        @booking = Booking.includes(:payment).find_by_id(booking_id)
        return unless refund_possible(user_id)
        @venue = @booking.space.venue

        refund = mangopay_refund(price_calculator(percentage, deposit))
        return save_refund_error(refund['ResultMessage']) if
            refund['Status'] == 'FAILED'
        save_refund(refund)
      rescue MangoPay::ResponseError => e
        save_refund_error(e.message, user_id)
      end

      private

      def init_log(booking_id, user_id)
        str = "Payments::Mangopay::RefundPayingWorker on booking_id: #{booking_id}, "
        str += "user_id: #{user_id}"
        Rails.logger.info(str)
      end

      def refund_possible?(user_id)
        @booking.present? && User.exists?(user_id) && @booking.payment.present? &&
          @booking.payment.payin_succeeded?
      end

      def save_refund_error(e, user_id)
        @booking.payment.update_attributes(error_message: e.to_s,
                                           transaction_status: 'REFUND_FAILED')
        BookingManager.change_booking_status(User.find(user_id), @booking,
                                             Booking.states[:error_refunding])
      end

      def mangopay_refund(price)
        currency = @venue.currency.upcase
        MangoPay::PayIn.refund(@booking.payment.transaction_id,
                               AuthorId: @booking.owner.mangopay_payment_account.mangopay_user_id,
                               DebitedFunds: {
                                 Currency: currency, Amount: price },
                               Fees: { Currency: currency, Amount: 0 })
      end

      def save_refund(transaction)
        @booking.payment.update_attributes(transaction_status: "REFUND_#{transaction['Status']}")
        BookingManager.change_booking_status(User.find(user_id), @booking,
                                             Booking.states[:cancelled]) unless percentage == 0 &&
                                                                                deposit
      end

      def price_calculator(percentage, deposit)
        price = @booking.price * percentage
        price += @booking.deposit if deposit
        (price * 100).to_i
      end
    end
  end
end