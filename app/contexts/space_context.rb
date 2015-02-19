class SpaceContext

  def initialize(space)
    @space = space
  end

  def can_update?(capacity_param, quantity_param)
    capacity_aux = (capacity_param || capacity).to_i
    quantity_aux = (quantity_param || quantity).to_i
    valid_quantity?(quantity_aux) && valid_capacity?(capacity_aux)
  end

  def valid_quantity?(new_quantity)
    return true if new_quantity >= @space.quantity
    delta_quantity = (new_quantity - @space.quantity).abs
    booking_attributes = { state: Booking.states[:pending_authorization],
                           from: Time.now.at_beginning_of_day - 1.day,
                           to: Time.now.advance(years: 1).at_end_of_day,
                           b_type: Booking.b_types[:hour], quantity: delta_quantity,
                           space: @space, owner: User.first }
    # TODO: el user debe ser el de la sesion
    BookingManager.bookable?(booking_attributes)
  end

  def valid_capacity?(new_capacity)

  end

  def update?(space_params)
    return false unless can_update?(space_params[:capacity], space_params[:quantity])
    @space.update_attributes(space_params)
  end

end
