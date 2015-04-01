module BookingsHelper

  def can_review?(booking, own = true)
    # TODO, use venue's timezone (not implemented yet)
    now = Time.zone.now
    owner?(booking, own) && now >= booking.from
  end

  def can_view_receipt?(booking, own = true)
    owner?(booking, own)
  end

  def can_cancel?(booking, own = true)
    owner?(booking, own) && cancellable_states(booking) && !finished?(booking)
  end

  def can_delete?(booking, own = true)
    owner?(booking, own) && !deleted?(booking, own) && (booking.canceled? || finished?(booking))
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

  def deleted?(booking, own = true)
    (own) ? booking.owner_delete? : booking.venue_owner_delete?
  end

  def owner?(booking, own = true)
    (own) ? booking.owner == current_represented : booking.space.venue.owner == current_represented
  end
end
