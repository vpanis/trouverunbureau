module BookingsHelper

  def review?(booking, own = true)
    # TODO, use venue's timezone (not implemented yet)
    now = Time.zone.now
    owner?(booking, own) && now >= booking.from
  end

  def view_receipt?(booking, own = true)
    owner?(booking, own)
  end

  def cancel?(booking, own = true)
    owner?(booking, own) && cancellable_states(booking) && !finished?
  end

  def delete?(booking, own = true)
    owner?(booking, own) && (booking.canceled? || finished?)
  end

  private

  def cancellable_states(booking)
    booking.paid? || booking.pending_authorization? || booking.pending_payment?
  end

  def finished?(booking)
    # TODO, use venue's timezone (not implemented yet)
    now = Time.zone.now
    now > (booking.to + 1)
  end

  def owner?(booking, own = true)
    (own) ? booking.owner == current_represented : booking.space.venue.owner == current_represented
  end
end
