class BookingNotificationWrapper < SimpleDelegator
  def recipients_emails
    represented_recipients(space.venue.owner) + represented_recipients(owner)
  end

  def venue_recipients_emails
    represented_recipients(space.venue.owner)
  end

  def client_recipients_emails
    represented_recipients(owner)
  end

  private

  def represented_recipients(owner)
    return [owner.email] if owner.is_a?(User)
    organization_members(owner) << owner.email
  end

  def organization_members(owner)
    owner.organization_users.joins(:user).pluck('users.email')
  end
end
