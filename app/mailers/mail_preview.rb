class MailPreview < MailView
  def new_message_email
    TestMailer.new_message_email('test@asd.com')
  end

  def host_cancellation_email
    TestMailer.host_cancellation_email('test@asd.com')
  end
end
