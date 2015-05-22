class MailPreview < MailView
  def new_message_email
    NotificationsMailer.new_message_email('test@asd.com')
  end

  def host_cancellation_email
    NotificationsMailer.host_cancellation_email(Message.where(m_type: Booking::states[:cancelled]).first.try(:id))
  end

  def guest_review_email
    NotificationsMailer.guest_review_email('test@asd.com')
  end

  def host_review_email
    NotificationsMailer.host_review_email('test@asd.com')
  end

  def receipt_email
    NotificationsMailer.receipt_email('test@asd.com')
  end

  def receipt_email_host
    NotificationsMailer.receipt_email_host('test@asd.com')
  end
end
