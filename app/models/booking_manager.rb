class BookingManager
  extend BookingReservation
  extend BookingInquiry

  @minute_granularity = 30

  class << self
    def book(user, booking_attributes = {})
      booking = Booking.new(booking_attributes)
      return [booking, nil] unless booking.valid?
      custom_errors = ActiveModel::Errors.new(booking)
      booking = check_if_can_book_and_perform(booking, 'FOR SHARE', custom_errors) do
        booking.save if custom_errors.empty?
      end
      creation_message(user, booking) if custom_errors.empty?
      [booking, custom_errors]
    end

    def update_booking(user, booking, new_booking_attributes = {})
      custom_errors = ActiveModel::Errors.new(booking)
      return [booking, custom_errors] unless booking_update_valid?(user, booking,
                                                                   new_booking_attributes,
                                                                   custom_errors)
      booking = check_if_can_book_and_perform(booking, 'FOR SHARE', custom_errors) do
        booking.save if custom_errors.empty?
      end if re_run_reservation?(booking)
      change_attributes_message(user, booking) if custom_errors.empty?
      [booking, custom_errors]
    end

    def bookable?(booking_attributes = {}, check_venue_hours = true)
      booking = Booking.new(booking_attributes)
      return false unless booking.valid?
      custom_errors = ActiveModel::Errors.new(booking)
      check_if_can_book_and_perform(booking, 'FOR SHARE', custom_errors, check_venue_hours) {}
      custom_errors.empty?
    end

    def change_booking_status(user, booking, state)
      custom_errors = ActiveModel::Errors.new(booking)
      verify_states_changes(user, booking, state, custom_errors)
      return [booking, custom_errors] unless custom_errors.empty?
      if state == Booking.states[:pending_payment]
        booking, custom_errors = change_to_pending_payment(booking, custom_errors)
      else
        booking.update_attributes(state: state)
      end
      state_change_message(user, booking, state) if booking.valid? && custom_errors.empty?
      [booking, custom_errors]
    end

    private

    def booking_update_valid?(user, booking, new_booking_attributes, custom_errors)
      verify_updatable_state(booking, custom_errors)
      new_booking_attributes.delete(:state) # just in case
      booking.assign_attributes(new_booking_attributes)
      verify_user(user, booking.space.venue.owner, custom_errors) # only the venue owner
      custom_errors.empty? && booking.valid? && !booking.changed_attributes.empty?
    end

    def verify_states_changes(user, booking, state, custom_errors)
      verify_valid_states_transitions(booking, state, custom_errors)
      if state == Booking.states[:paid] || state == Booking.states[:cancelled] ||
        state == Booking.states[:payment_verification]
        verify_user(user, booking.owner, custom_errors)
      else
        verify_user(user, booking.space.venue.owner, custom_errors)
      end
    end

    def change_to_pending_payment(booking, custom_errors)
      [check_if_can_book_and_perform(booking, 'FOR UPDATE', custom_errors) do
        if custom_errors.empty?
          booking.update_attributes(state: Booking.states[:pending_payment], approved_at: Time.new)
        end
      end, custom_errors]
    end

    def verify_user(user, owner, custom_errors)
      return if user.user_can_write_in_name_of(owner)
      custom_errors.add(:not_allowed_user, user_id: user.id)
    end

    def verify_updatable_state(booking, custom_errors)
      return if Booking.states[booking.state] == Booking.states[:pending_authorization]
      custom_errors.add(:unupdatable_state, state: booking.state)
    end

    def verify_valid_states_transitions(booking, state, custom_errors)
      custom_errors.add(:invalid_state, state: state) unless Booking.states.values.include? state
      custom_errors.add(:invalid_transition, state: state) if invalid_transition?(state, booking)
      custom_errors.add(:same_state, state: state) if state == booking.state
    end

    def invalid_transition?(state, booking)
      (state == Booking.states[:pending_payment] && !booking.pending_authorization?) ||
        (state == Booking.states[:payment_verification] && !booking.pending_payment?) ||
        (state == Booking.states[:paid] && !booking.pending_verification?)
    end
  end

end
