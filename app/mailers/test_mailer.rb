class TestMailer < ActionMailer::Base # Remove this file when create the mailers
  default from: 'from@test.com'

  def new_message_email(email)
    mail(to: email, subject: 'test')
  end

  def host_cancellation_email(email)
    mail(to: email, subject: 'test')
  end

end
