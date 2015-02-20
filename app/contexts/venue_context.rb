class VenueContext

  def initialize(venue, current_represented)
    @venue = venue
    @current_represented = current_represented
  end

  def owner?
    @current_represented.present? && @space.venue.owner == @current_represented
  end

  def update_venue?(venue_params)
    return false unless owner?
    @venue.update_attributes!(venue_params)
  end

end
