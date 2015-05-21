module BookingsHelper

  def can_review?(booking, own = true)
    now = Time.current
    owner?(booking, own) && now >= booking.space.venue.time_zone.from_zone_to_utc(booking.from)
  end

  def can_view_receipt?(booking, own = true)
    owner?(booking, own)
  end

  def can_cancel?(booking, own = true)
    owner?(booking, own) && cancellable_states(booking) && !finished?(booking)
  end

  def can_delete?(booking, own = true)
    owner?(booking, own) && !deleted?(booking, own) && (booking.cancelled? || finished?(booking))
  end

  private

  def cancellable_states(booking)
    booking.paid? || booking.pending_authorization? || booking.pending_payment?
  end

  def finished?(booking)
    Time.current > booking.space.venue.time_zone.from_zone_to_utc(booking.to)
  end

  def deleted?(booking, own = true)
    (own) ? booking.owner_delete? : booking.venue_owner_delete?
  end

  def owner?(booking, own = true)
    (own) ? booking.owner == current_represented : booking.space.venue.owner == current_represented
  end
end
