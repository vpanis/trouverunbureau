module BookingsHelper

  def initialize(booking, represented)
    @booking = booking
    @represented = represented
  end

  def review?
    now = Time.zone.now
    now >= @booking.from
  end

  def view_receipt?
    true
  end

  def cancel?
    # TODO, use venue's timezone (not implemented yet)
    now = Time.zone.now
    @booking.owner == @represented && !booking.canceled?
  end

  def delete?
    booking.owner == @represented
  end

  private

  def
end
