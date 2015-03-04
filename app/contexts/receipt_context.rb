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
    Receipt.create!(booking_id: booking.id)
  end

  def get_receipt(booking)
    return false unless owner?
    Receipt.where(booking_id: booking.id).first
  end

  def owner?(booking)
    booking.owner == @current_represented
  end
end
