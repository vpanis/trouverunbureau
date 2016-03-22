class LocaleMailer < Devise::Mailer
  default from: ENV['MAIL_FROM_NAME'] + " <" + ENV['MAIL_FROM_ADDRESS'] + ">" || 'No Reply <from@test.com>'

  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def reset_password_instructions(record, token, opts = {})
    I18n.with_locale(record.language) do
      super
    end
  end
end
