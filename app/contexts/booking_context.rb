class BookingContext
  def initialize(current_represented)
    @current_represented = current_represented
  end

  def retrieve_state_bookings(states)
    user.bookings.where {state.in states}.includes {space.venue}

  end

end
