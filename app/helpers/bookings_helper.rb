module BookingsHelper

  def review?(booking)
    # TODO, use venue's timezone (not implemented yet)
    now = Time.zone.now
    owner?(booking) && now >= booking.from
  end

  def view_receipt?(booking)
    true
  end

  def cancel?(booking)
    !delete?(booking)
  end

  def delete?(booking)
    owner?(booking) && (booking.canceled? || finished?)
  end

  private

  def finished?(booking)
    # TODO, use venue's timezone (not implemented yet)
    now = Time.zone.now
    now > (booking.to + 1)
  end

  def owner?(booking)
    booking.owner == current_represented
  end
end
