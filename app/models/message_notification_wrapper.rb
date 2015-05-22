class MessageNotificationWrapper < SimpleDelegator

  # if the one who sent the message is the booker, then send the email to the venue users
  # else, send the email to the booker
  def recipients_emails
    booking.owner == user ? venue_recipients : booking.owner.email
  end

  def recipient_name
    booking.owner == user ? booking.space.venue.owner.name : booking.owner.name
  end

  def from
    represented.name
  end

  def message_text
    text || I18n.t("messages.#{m_type}")
  end

  def venue_recipients
    booking.space.venue.owner.is_a?(User) ? booking.space.venue.owner.email : organization_members
  end

  private

  def organization_members
    booking.space.venue.owner.organization_users.joins(:user).pluck('users.email')
  end

end
