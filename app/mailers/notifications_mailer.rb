class NotificationsMailer < ActionMailer::Base
  default from: 'from@test.com'

  def new_message_email(message_id)
    send_email(fetch_message(message_id), 'hola')
  end

  def host_cancellation_email(message_id)
    send_email(fetch_message(message_id), 'hola')
  end

  def guest_review_email(message_id)
    send_email(fetch_message(message_id), 'hola')
  end

  def host_review_email(message_id)
    send_email(fetch_message(message_id), 'hola')
  end

  def receipt_email(message_id)
    send_email(fetch_message(message_id), 'hola')
  end

  def receipt_email_host(message_id)
    send_email(fetch_message(message_id), 'hola')
  end

  private

  def fetch_message(id)
    MessageNotificationWrapper.new(Message.find(id))
  end

  def send_email(message, subject)
    @message = message
    mail(to: message.recipients_emails, subject: subject)
  end
end
