class VenueContext

  def initialize(venue, current_represented)
    @venue = venue
    @current_represented = current_represented
  end

  def can_update?
    owner? && valid_venue_hours?
  end

  def owner?
    @current_represented.present? && @venue.owner == @current_represented
  end

  def update_venue?(venue_params)
    # return false unless can_update?
    @venue.update_attributes!(venue_params)
  end

  def valid_venue_hours?
    date_from = Time.zone.now.at_beginning_of_day - 1.day
    no_bookings?(date_from)
  end

  def no_bookings?(date_from)
    spaces_id = @venue.spaces.ids
    Booking.where { (id.in spaces_id) & (from >= date_from) & (state == Booking.states["paid"] ||
      state == Booking.states["pending_payment"]) }.empty?
  end
end
