class ReceiptContext

  def initialize(current_represented)
    @current_represented = current_represented
  end

  def can_create_receipt?(booking)
    # TODO, ver logica del pago
    owner?(booking) && booking.paid?
  end

  def create_receipt(booking)
    return false unless can_create_receipt?(booking)
    owner = booking.owner
    Receipt.create(booking_id: booking.id, guest_first_name: owner.first_name,
                   guest_last_name: owner.last_name, guest_avatar: owner.avatar,
                   guest_location: owner.location, guest_email: owner.email,
                   guest_phone: owner.phone)
  end

  def get_receipt(booking)
    return nil unless authorized?(booking)
    booking.receipt
  end

  def owner?(booking)
    booking.owner == @current_represented
  end

  def authorized?(booking)
    owner?(booking) || venue_owner?(booking)
  end

  private

  def venue_owner?(booking)
    booking.space.venue.owner == @current_represented
  end
end
