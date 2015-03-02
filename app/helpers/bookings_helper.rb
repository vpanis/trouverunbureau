module BookingsHelper

  def review?(booking)
    # TODO, use venue's timezone (not implemented yet)
    now = Time.zone.now
    owner?(booking) && now >= booking.from
  end

  def view_receipt?
    owner?(booking)
  end

  def cancel?(booking)
    owner?(booking) && cancellable_states(booking) && !finished?
  end

  def delete?(booking)
    owner?(booking) && (booking.canceled? || finished?)
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

  def owner?(booking)
    booking.owner == current_represented
  end
end
