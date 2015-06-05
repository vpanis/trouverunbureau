module Payments
  class PayinSuccessForHookWorker
    include Sidekiq::Worker

    def perform(transaction_id, date_i, retry_count)
      init_log(transaction_id)
      @mangopay_payment = MangopayPayment.find_by(transaction_id: transaction_id)
      return retry_worker(transaction_id, date_i, retry_count) unless
        @mangopay_payment.present? && @mangopay_payment.notification_date_int.to_i < date_i

      save_payment(date_i)
    end

    private

    def init_log(transaction_id)
      str = "Payments::PayinSuccessForHookWorker on transaction_id: #{transaction_id}"
      Rails.logger.info(str)
    end

    def save_payment(date_i)
      @mangopay_payment.update_attributes(transaction_status: 'PAYIN_SUCCEEDED',
                                          notification_date_int: date_i)
      BookingManager.change_booking_status(
        @mangopay_payment.user_paying, @mangopay_payment.booking, Booking.states[:paid])
      notify
    end

    def retry_worker(transaction_id, date_i, retry_count)
      PayinSuccessForHookWorker.perform_in(retry_count.minutes + 1.second, transaction_id, date_i,
                                           retry_count + 1) if
        retry_count < Rails.configuration.payment.notification_attempts
    end

    def notify
      NotificationsMailer.delay.receipt_email(@mangopay_payment.booking.id)
      NotificationsMailer.delay.receipt_email_host(@mangopay_payment.booking.id)
    end
  end
end
