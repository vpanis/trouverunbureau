class TestMailer < ActionMailer::Base # Remove this file when create the mailers
  default from: 'from@test.com'

  def new_message_email(email)
    mail(to: email, subject: 'test')
  end

  def host_cancellation_email(email)
    mail(to: email, subject: 'test')
  end

  def guest_review_email(email)
    mail(to: email, subject: 'test')
  end

  def host_review_email(email)
    mail(to: email, subject: 'test')
  end

  def receipt_email(email)
    mail(to: email, subject: 'test')
  end

end
