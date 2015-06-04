module Payments
  class PayoutSuccessForHookWorker
    include Sidekiq::Worker

    def perform(transaction_id, date_i, retry_count, refund)
      init_log(transaction_id)
      @payout = MangopayPayout.find_by(transaction_id: transaction_id, p_type: p_type(refund))
      return retry_worker(transaction_id, date_i, retry_count, refund) unless
        @payout.present? && @payout.notification_date_int.to_i < date_i

      save_payout(date_i)
    end

    private

    def init_log(transaction_id)
      str = 'Payments::Mangopay::PayoutSuccessForHookWorker on '
      str += "payout_id: #{transaction_id}, #{ (refund) ? 'Refund' : 'Payout'}"
      Rails.logger.info(str)
    end

    def save_payout(_e, date_i)
      @payout.update_attributes(transaction_status: 'TRANSACTION_SUCCEEDED',
                                notification_date_int: date_i)
      b = @payout.mangopay_payment.booking
      BookingManager.change_booking_status(@payout.user, b,
                                           b.state_if_represented_cancels(@payout.represented)) if
        b.state == 'refunding'
      notify
    end

    def retry_worker(transaction_id, date_i, retry_count, refund)
      PayoutSuccessForHookWorker.perform_in(retry_count.minutes + 1.second, transaction_id, date_i,
                                            retry_count + 1, refund) if
        retry_count < Rails.configuration.payment.notification_attempts
    end

    def p_type(refund)
      return MangopayPayout.p_types[:refund] if refund
      MangopayPayout.p_types[:payout_to_user]
    end

    def notify
      NotificationsMailer.delay.receipt_email(@payout.mangopay_payment.booking.id) if
        @payout.refund?
      NotificationsMailer.delay.receipt_email_host(@payout.mangopay_payment.booking.id) if
        @payout.payout_to_user?
    end
  end
end
