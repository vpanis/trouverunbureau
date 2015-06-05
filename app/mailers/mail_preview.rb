class MailPreview < MailView
  def new_message_email
    id = Message.first.try(:id)
    NotificationsMailer.new_message_email(id)
  end

  def host_cancellation_email
    id = Message.where(m_type: Booking.states[:cancelled]).first.try(:id)
    NotificationsMailer.host_cancellation_email(id)
  end

  def guest_review_email
    id = Booking.first.try(:id)
    NotificationsMailer.guest_review_email(id)
  end

  def host_review_email
    id = Booking.first.try(:id)
    NotificationsMailer.host_review_email(id)
  end

  def receipt_email
    id = MangopayPayment.where(transaction_status: 'PAYIN_SUCCEEDED')
                .first.try(:booking).try(:id)
    NotificationsMailer.receipt_email(id)
  end

  def receipt_email_host
    id = MangopayPayout.where(transaction_status: 'TRANSACTION_SUCCEEDED')
                .first.try(:mangopay_payment).try(:booking).try(:id)
    NotificationsMailer.receipt_email_host(id)
  end
end
