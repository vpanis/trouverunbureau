class BookingContext
  def initialize(current_represented)
    @current_represented = current_represented
  end

  def retrieve_bookings(states)
    @current_represented.bookings.where { state.in states }.not_deleted_owner
                                 .includes { space.venue }
  end

  def retrieve_bookings_venues(states)
    venue_ids = @current_represented.venues.ids
    Booking.joins { space }.where { (space.venue_id.in venue_ids) & (state.in states) }
                           .not_deleted_venue_owner.includes { space.venue }
  end

  def delete(booking)
    del_owner = delete_booking(booking) if booking.owner == @current_represented
    del_venue = delete_venue_booking(booking) if booking.space.venue.owner == @current_represented
    del_owner || del_venue
  end

  private

  def delete_booking(booking)
    booking.update_attributes(owner_delete: true)
  end

  def delete_venue_booking(booking)
    booking.update_attributes(venue_owner_delete: true)
  end
end
