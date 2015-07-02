class BookingNotificationWrapper < SimpleDelegator
  def recipients_users
    represented_recipients(space.venue.owner) + represented_recipients(owner)
  end

  def venue_recipients_users
    represented_recipients(space.venue.owner)
  end

  def client_recipients_users
    represented_recipients(owner)
  end

  private

  def represented_recipients(owner)
    return [owner] if owner.is_a?(User)
    organization_members(owner) << owner
  end

  def organization_members(owner)
    owner.users
  end
end
