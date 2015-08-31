module BookingReservation

  def block_states
    [Booking.states[:pending_payment], Booking.states[:paid],
     Booking.states[:payment_verification]]
  end

  private

  def check_if_can_book_and_perform(booking, lock, custom_errors, check_venue_hours = true, &block)
    custom_errors.add(:from_in_the_past,
      from: booking.from) if booking.from < booking.space.venue.time_zone.from_zone_to_utc(Time.current)
    check_availability(booking, custom_errors, check_venue_hours)
    return booking unless booking.valid? && custom_errors.empty?
    check_max_collition(booking, lock, custom_errors, &block)
    booking
  end

  def check_availability(booking, custom_errors, check_venue_hours)
    verify_quantity(booking, custom_errors)
    custom_errors.add(:from_date_bigger_than_to,
                      from: booking.from, to: booking.to) if booking.from > booking.to
    return if !check_venue_hours || valid_hours_for_venue?(booking)
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
      rdc.errors.each { |err| custom_errors.add(:collition_errors, err) } unless rdc.errors.empty?
      yield
    end
  end

  def retrieve_bookings_that_collide_with(booking, lock)
    Booking.lock(lock).where(':from <= bookings.to AND :to >= bookings.from',
                             from: booking.from, to: booking.to).where(space: booking.space)
      .where { state.eq_any my { block_states } }
      .order(from: :asc)
  end

  def valid_hours_for_venue?(booking)
    case Booking.b_types[booking.b_type]
    when Booking.b_types[:hour]
      booking.space.venue.opens_hours_from_to?(booking.from, booking.to)
    when Booking.b_types[:day]
      booking.space.venue.opens_at_least_one_day_from_to?(booking.from, booking.to)
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
