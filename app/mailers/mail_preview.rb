class MailPreview < MailView
  def welcome_email
    id = User.last.try(:id)
    NotificationsMailer.welcome_email(id)
  end

  def new_message_email
    message = Message.last
    to_whom = message.destination_recipient

    NotificationsMailer.new_message_email(message.id, to_whom)
  end

  def host_cancellation_email_for_host
    id = Message.where(m_type: Booking.states[:denied]).last.try(:id)
    NotificationsMailer.host_cancellation_email(id, 'host')
  end

  def host_cancellation_email_for_guest
    id = Message.where(m_type: Booking.states[:denied]).last.try(:id)
    NotificationsMailer.host_cancellation_email(id, 'guest')
  end

  def guest_cancellation_email_for_guest
    id = Message.where(m_type: Booking.states[:cancelled]).last.try(:id)
    NotificationsMailer.guest_cancellation_email(id, 'guest')
  end

  def guest_cancellation_email_for_host
    id = Message.where(m_type: Booking.states[:cancelled]).last.try(:id)
    NotificationsMailer.guest_cancellation_email(id, 'host')
  end

  def guest_review_email
    id = Booking.last.try(:id)
    NotificationsMailer.guest_review_email(id)
  end

  def host_review_email
    id = Booking.last.try(:id)
    NotificationsMailer.host_review_email(id)
  end

  def receipt_email
    id = MangopayPayment.where(transaction_status: 'PAYIN_SUCCEEDED')
                .last.try(:booking).try(:id)
    NotificationsMailer.receipt_email(id)
  end

  def receipt_email_host
    id = MangopayPayment.where(transaction_status: 'PAYIN_SUCCEEDED')
                .last.try(:booking).try(:id)
    NotificationsMailer.receipt_email_host(id)
  end

  def aig_claim_email
    id = Booking.last.try(:id)
    NotificationsMailer.aig_claim_email(id)
  end
end
