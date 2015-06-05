class NotificationsMailer < ActionMailer::Base
  default from: 'from@test.com'

  def new_message_email(message_id)
    message = prepare_message_data(message_id)
    send_email(message.recipients_emails,
               t('new_message_email.subject', booking_id: message.booking.id))
  end

  def host_cancellation_email(message_id)
    message = prepare_message_data(message_id)
    send_email(message.recipients_emails,
               t('host_cancellation_email.subject', booking_id: message.booking.id))
  end

  def guest_review_email(booking_id)
    booking = prepare_booking_data(booking_id)
    send_email(booking.client_recipients_emails,
               t('guest_review_email.subject', type: booking.owner.class.to_s,
                                               guest_id: booking.owner.id))
  end

  def host_review_email(booking_id)
    booking = prepare_booking_data(booking_id)
    send_email(booking.venue_recipients_emails,
               t('host_review_email.subject', venue_id: booking.space.venue.id))
  end

  def receipt_email(booking_id)
    booking = prepare_receipt_data(booking_id)
    send_email(booking.client_recipients_emails,
               t('receipt_email.subject_client', booking_id: booking.id))
  end

  def receipt_email_host(booking_id)
    booking = prepare_receipt_data(booking_id)
    send_email(booking.venue_recipients_emails,
               t('receipt_email.subject_host', booking_id: booking.id))
  end

  private

  def prepare_message_data(id)
    @message = MessageNotificationWrapper.new(Message.find(id))
  end

  def prepare_booking_data(id)
    @booking = BookingNotificationWrapper.new(Booking.find(id))
  end

  def prepare_receipt_data(id)
    @booking = BookingNotificationWrapper.new(
      Booking.includes(payment: [:receipt, mangopay_payouts: [:receipt]], space: [:venue])
             .find(id))
    calculate_lists
    @booking
  end

  def send_email(recipients_emails, subject)
    mail(to: recipients_emails, subject: subject)
  end

  def calculate_lists
    @payment = @booking.payment
    @refunds = []
    @payouts_to_user = []
    @payment.mangopay_payouts.each do |mp|
      return unless mp.transaction_succeeded?
      return @refunds << mp if mp.refund?
      @payouts_to_user << mp
    end
  end
end
