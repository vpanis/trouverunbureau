class Contact < MailForm::Base
  attribute :name, validate: true
  attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: I18n.t('contact.subject'),
      to: info_email,
      from: "Deskspotting <#{info_email}>"
    }
  end

  def info_email
    @info_email = AppConfiguration.for(:deskspotting).contact_us unless @info_email.present?
    @info_email
  end
end
