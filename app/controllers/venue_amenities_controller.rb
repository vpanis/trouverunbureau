class VenueAmenitiesController < VenuesController

  def amenities
    @venue = Venue.find(params[:id])
    return unless can_edit?
  end

  def save_amenities
    @venue = Venue.find(params[:id])
    return unless can_edit?
    @venue.update_attributes!(amenities: amenities_params)
    redirect_to photos_venue_path(@venue)
  end

  private

  def amenities_params
    params.require(:venue).permit(amenities: [])[:amenities].reject(&:empty?)
  end

end
