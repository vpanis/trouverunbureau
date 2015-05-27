class NotificationsMailer < ActionMailer::Base
  default from: 'from@test.com'

  def new_message_email(message_id)
    message = fetch_message(message_id)
    send_email(message, t('new_message_email.subject', from: message.from))
  end

  def host_cancellation_email(message_id)
    send_email(fetch_message(message_id), 'Host Cancellation')
  end

  def guest_review_email(message_id)
    send_email(fetch_message(message_id), 'Guest Review')
  end

  def host_review_email(message_id)
    send_email(fetch_message(message_id), 'Host Review')
  end

  def receipt_email(message_id)
    send_email(fetch_message(message_id), 'Receipt')
  end

  def receipt_email_host(message_id)
    send_email(fetch_message(message_id), 'Receipt Host')
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
