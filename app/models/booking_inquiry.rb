module BookingInquiry

  def bookings_with_news(represented)
    Booking.joins { space.venue }.joins { messages }.where do
      ((owner == my { represented }) & ((messages.created_at > bookings.owner_last_seen) |
        (bookings.owner_last_seen.eq nil))) |
      ((space.venue.owner ==  my { represented }) &
        ((messages.created_at > bookings.venue_last_seen) | (bookings.venue_last_seen.eq nil)))
    end.distinct
  end

  def booking_with_news?(booking, represented)
    last_message_date = booking.messages.last.created_at
    if represented == booking.owner
      last_message_date > booking.owner_last_seen
    else
      last_message_date > booking.venue_last_seen
    end
  end

  def change_last_seen(booking, represented, last_seen)
    booking.owner_last_seen = last_seen if booking.owner == represented
    booking.venue_last_seen = last_seen if booking.space.venue.owner == represented
    booking.save
  end

  def creation_message(user, booking)
    state_change_message(user, booking, Message.m_types[:pending_authorization])
  end

  def change_attributes_message(user, booking)
    message = booking.messages.create(represented: booking.space.venue.owner,
                                      user: user,
                                      m_type: Message.m_types[:booking_change])
    change_last_seen(booking, booking.space.venue.owner, message.created_at)
  end

  private

  def state_change_message(user, booking, state)
    return booking unless user.present?
    message = booking.messages.create(represented: booking.owner,
                                      user: user,
                                      m_type: booking_state_to_message_state(state))
    change_last_seen(booking, booking.owner, message.created_at)
  end

  def booking_state_to_message_state(state)
    case state
    when Booking.states[:pending_payment]
      Message.m_types[:pending_payment]
    when Booking.states[:paid]
      Message.m_types[:paid]
    when Booking.states[:canceled]
      Message.m_types[:canceled]
    when Booking.states[:denied]
      Message.m_types[:denied]
    end
  end

end
