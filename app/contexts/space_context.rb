class SpaceContext

  def initialize(space)
    @space = space
  end

  def can_update?(capacity_param, quantity_param)
    capacity_aux = (capacity_param || @space.capacity).to_i
    quantity_aux = (quantity_param || @space.quantity).to_i
    valid_quantity?(quantity_aux) && valid_capacity?(capacity_aux)
  end

  def valid_quantity?(new_quantity)
    return true if new_quantity >= @space.quantity
    delta_quantity = @space.quantity - new_quantity
    booking_attributes = { state: Booking.states[:paid],
                           from: Time.zone.now.at_beginning_of_day - 1.day,
                           to: Time.zone.now.advance(years: 1).at_end_of_day,
                           b_type: Booking.b_types[:month], quantity: delta_quantity,
                           price: 1, space: @space, owner: User.first }
    # TODO: el user debe ser el de la sesion
    BookingManager.bookable2?(booking_attributes)
  end

  def valid_capacity?(new_capacity)
    return true if new_capacity >= @space.capacity
    date_from = Time.zone.now.at_beginning_of_day - 1.day
    date_to = Time.zone.now.advance(months: 1).at_end_of_day
    result =  @space.bookings.where { (from >= date_from) & (to <= date_to) }
    !result.present?
  end

  def update?(space_params)
    return false unless can_update?(space_params[:capacity], space_params[:quantity])
    @space.update_attributes(space_params)
  end

end
