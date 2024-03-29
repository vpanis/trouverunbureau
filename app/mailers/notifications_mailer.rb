class NotificationsMailer < ActionMailer::Base
  default from: "#{ENV['MAIL_FROM_NAME']} <#{ENV['MAIL_FROM_ADDRESS']}>" || 'No Reply <from@test.com>'

  def new_message_email(message_id, for_type)
    @for_type = for_type
    message = prepare_message_data(message_id)
    return send_i18n_email(message.venue_recipients_representees,
                           'new_message_email.subject',
                           booking_id: message.booking.id,
                           venue_name: message.booking.space.venue.name,
                           checking_date: message.booking.created_at.strftime("%Y-%m-%d %H:%M"),
                           type: I18n.t("wishlist.#{message.booking.b_type}")) if for_type == 'host'

    send_i18n_email(message.client_recipients_representees,
                    'new_message_email.subject',
                    booking_id: message.booking.id,
                    venue_name: message.booking.space.venue.name,
                    checking_date: message.booking.created_at.strftime("%Y-%m-%d %H:%M"),
                    type: I18n.t("wishlist.#{message.booking.b_type}")) if for_type == 'guest'
  end

  def host_cancellation_email(message_id, for_type)
    @for_type = for_type
    message = prepare_message_data(message_id)
    return send_i18n_email(message.venue_recipients_representees,
                           'host_cancellation_email.subject',
                           booking_id: message.booking.id) if for_type == 'host'
    send_i18n_email(message.client_recipients_representees, 'host_cancellation_email.subject',
                    booking_id: message.booking.id) if for_type == 'guest'
  end

  def guest_cancellation_email(message_id, for_type)
    @for_type = for_type
    message = prepare_message_data(message_id)
    return send_i18n_email(message.venue_recipients_representees,
                           'guest_cancellation_email.subject',
                           booking_id: message.booking.id) if for_type == 'host'
    send_i18n_email(message.client_recipients_representees, 'guest_cancellation_email.subject',
                    booking_id: message.booking.id) if for_type == 'guest'
  end

  def guest_review_email(booking_id)
    booking = prepare_booking_data(booking_id)
    send_i18n_email(booking.client_recipients_representees, 'guest_review_email.subject',
                    guest_id: booking.owner.name,
                    type: booking.space.venue.name)
  end

  def host_review_email(booking_id)
    booking = prepare_booking_data(booking_id)
    send_i18n_email(booking.venue_recipients_representees, 'host_review_email.subject',
                    host_id: booking.space.venue.owner.first_name,
                    guest_id: booking.owner.name)
  end

  def receipt_email(booking_id)
    booking = prepare_receipt_data(booking_id)
    send_i18n_email(booking.client_recipients_representees, 'receipt_email.subject_client',
                    booking_id: booking.id)
  end

  def receipt_email_host(booking_id)
    booking = prepare_receipt_data(booking_id)
    send_i18n_email(booking.venue_recipients_representees, 'receipt_email.subject_host',
                    booking_id: booking.id)
  end

  def welcome_email(user_id)
    @user = User.find(user_id)
    send_i18n_email([@user], 'welcome_email.subject')
  end

  def aig_claim_email(booking_id)
    # attachments['attachment.pdf'] = File.read('attachment.pdf')
    booking = prepare_receipt_data(booking_id)

    aig_email = User.new(email: ENV['AIG_CLAIM_EMAIL'])

    send_i18n_email([aig_email], 'aig_claim_email.subject',
                    booking_id: booking.id, receipts: [1,2,3])
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

  def send_i18n_email(recipients_representees, subject_key, subject_params = {})
    emails_in_language = language_user_separator(recipients_representees)
    emails_in_language.each_pair do |language, emails|
      I18n.with_locale(language) do
        send_email(emails, I18n.t(subject_key, subject_params))
      end
    end
  end

  def language_user_separator(recipient_representees)
    emails_in_language = {}
    recipient_representees.each do |representee|
      user = representee
      user = representee.organization_users.first.user if representee.is_a?(Organization)
      language = user.language || I18n.default_locale.to_s
      emails_in_language[language] = [] unless emails_in_language.key?(language)
      emails_in_language[language] << representee.email
    end
    emails_in_language
  end

  def send_email(recipients_emails, subject)
    mail(to: recipients_emails, subject: subject)
  end

  def calculate_lists
    @payment = @booking.payment
    @refunds = []
    @payouts_to_user = []
    @payment.mangopay_payouts.each do |mp|
      @refunds << mp if mp.transaction_succeeded? && mp.refund?
      @payouts_to_user << mp if mp.transaction_succeeded? && mp.payout_to_user?
    end
  end
end
