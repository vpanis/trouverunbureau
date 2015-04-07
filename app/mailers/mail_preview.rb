class MailPreview < MailView
  def new_message_email
    TestMailer.new_message_email('test@asd.com')
  end

  def host_cancellation_email
    TestMailer.host_cancellation_email('test@asd.com')
  end

  def guest_review_email
    TestMailer.guest_review_email('test@asd.com')
  end

  def host_review_email
    TestMailer.host_review_email('test@asd.com')
  end
end
