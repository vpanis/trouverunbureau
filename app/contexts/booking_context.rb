class BookingContext
  def initialize(current_represented)
    @current_represented = current_represented
  end

  def retrieve_bookings(states)
    # Booking.where { state.in states }.includes { space.venue }
    @current_represented.bookings.where { state.in states }.includes { space.venue }
  end

  def retrieve_bookings_venues(states)
    venue_ids = @current_represented.venues.ids
    Booking.joins { space }.where { (space.venue_id.in venue_ids) & (state.in states) }
                           .includes { space.venue }
  end

end
