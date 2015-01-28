class BookingManager

  class << self

    def book(attributes = {})
      booking = Booking.new(attributes)
      return booking unless booking.valid?
      check_if_can_book_and_perform(booking, 'FOR SHARE') do
        booking.save if booking.errors.empty?
      end
    end

    def bookable?(attributes = {})
      booking = Booking.new(attributes)
      return false unless booking.valid?
      booking = check_if_can_book_and_perform(booking, 'FOR SHARE') {}
      booking.errors.empty?
    end

    def block_states
      [Booking.states[:pending_payment], Booking.states[:paid]]
    end

    def change_to_pending_payment(booking)
      check_if_can_book_and_perform(booking, 'FOR UPDATE') do
        if booking.errors.empty?
          booking.state = Booking.states[:pending_payment]
        else
          booking.state = Booking.states[:already_taken]
        end
        booking.save
      end
    end

    private

    def check_if_can_book_and_perform(booking, lock, &block)
      check_availability(booking)
      return booking unless booking.errors.empty?
      check_max_collition(booking, lock, &block)
      booking
    end

    def check_availability(booking)
      verify_quantity(booking)
      booking.errors.add(:from_date_bigger_than_to,
                         from: booking.from, to: booking.to) if booking.from > booking.to
      return if valid_hours_for_venue?(booking)
      booking.errors.add(:invalid_venue_hours, from: booking.from, to: booking.to)
    end

    def check_max_collition(booking, lock)
      Booking.transaction do
        rdc = RangeDateCollider.new(first_date: booking.from, minute_granularity: 30,
                max_collition_permited: booking.space.quantity - booking.quantity)
        retrieve_bookings_that_collide_with(booking, lock).each do |element|
          rdc.add_time_range(element.from, element.to, element.quantity)
          break unless rdc.valid?
        end
        booking.errors.add(:collition_errors, rdc.errors)
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

    def verify_quantity(booking)
      return unless booking.space.quantity < booking.quantity
      booking.errors.add(:quantity_exceed_max, quantity: booking.quantity)
    end
  end

end
