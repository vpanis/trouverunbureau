class BookingContext
  def initialize(current_represented, venue_ids)
    @current_represented = current_represented
    @venue_ids = (venue_ids.empty?) ? @current_represented.venues.ids : venue_ids
  end

  def retrieve_bookings(states)
    @current_represented.bookings.where { state.in states }.not_deleted_owner
                                 .includes { space.venue }.order('bookings.from asc')
  end

  def retrieve_bookings_venues(states)
    venue_bookings(states).order('bookings.from asc')
  end

  def delete(booking)
    del_owner = delete_booking(booking) if booking.owner == @current_represented
    del_venue = delete_venue_booking(booking) if booking.space.venue.owner == @current_represented
    del_owner || del_venue
  end

  private

  def venue_bookings(states)
    Booking.joins { space }.where { (space.venue_id.in my { @venue_ids }) & (state.in states) }
                           .not_deleted_venue_owner.includes { space.venue }
  end

  def delete_booking(booking)
    booking.update_attributes!(owner_delete: true)
  end

  def delete_venue_booking(booking)
    booking.update_attributes!(venue_owner_delete: true)
  end
end
