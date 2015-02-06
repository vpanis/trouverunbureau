module BookingReservation

  def block_states
    [Booking.states[:pending_payment], Booking.states[:paid]]
  end

  private

  def check_if_can_book_and_perform(booking, lock, custom_errors, &block)
    check_availability(booking, custom_errors)
    return booking unless booking.errors.empty?
    check_max_collition(booking, lock, custom_errors, &block)
    booking
  end

  def check_availability(booking, custom_errors)
    verify_quantity(booking, custom_errors)
    custom_errors.add(:from_date_bigger_than_to,
                      from: booking.from, to: booking.to) if booking.from > booking.to
    return if valid_hours_for_venue?(booking)
    custom_errors.add(:invalid_venue_hours, from: booking.from, to: booking.to)
  end

  def check_max_collition(booking, lock, custom_errors)
    Booking.transaction do
      rdc = RangeDateCollider.new(first_date: booking.from, minute_granularity:
        @minute_granularity, max_collition_permited: booking.space.quantity - booking.quantity)
      retrieve_bookings_that_collide_with(booking, lock).each do |element|
        rdc.add_time_range(element.from, element.to, element.quantity)
        break unless rdc.valid?
      end
      custom_errors.add(:collition_errors, rdc.errors) unless rdc.errors.empty?
      yield
    end
  end

  def retrieve_bookings_that_collide_with(booking, lock)
    Booking.lock(lock).where(':from BETWEEN bookings.from AND bookings.to OR
      :to BETWEEN bookings.from AND bookings.to', from: booking.from, to: booking.to)
      .where(space: booking.space).where { state.eq_any my { block_states } }
      .order(from: :asc)
  end

  def valid_hours_for_venue?(booking)
    case Booking.b_types[booking.b_type]
    when Booking.b_types[:hour]
      booking.space.venue.opens_hours_from_to?(booking.from, booking.to)
    when Booking.b_types[:day]
      booking.space.venue.opens_days_from_to?(booking.from, booking.to)
    else
      # if the venue opens at least 1 hour, 1 day per week, the user can book for week and month
      !booking.space.venue.day_hours.empty?
    end
  end

  def verify_quantity(booking, custom_errors)
    return unless booking.space.quantity < booking.quantity
    custom_errors.add(:quantity_exceed_max, quantity: booking.quantity)
  end

  def re_run_reservation_for_modified_attributes
    [:from, :to, :quantity]
  end

  def re_run_reservation?(booking)
    aux_array = re_run_reservation_for_modified_attributes.map(&:to_s)
    !(booking.changed_attributes.keys & aux_array).empty?
  end

end
