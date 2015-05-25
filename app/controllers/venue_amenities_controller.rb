class VenueAmenitiesController < VenuesController

  def amenities
    @venue = Venue.find(params[:id])
    return unless can_edit?
  end

  def save_amenities
    @venue = VenueAmenitiesValidator.new(Venue.find(params[:id]))
    return unless can_edit?
    @venue.assign_attributes(amenities: amenities_params)
    if @venue.valid?
      @venue.update_attributes!(amenities: amenities_params)
      redirect_to photos_venue_path(@venue)
    else
      render :amenities
    end
  end

  private

  def amenities_params
    params.require(:venue).permit(amenities: [])[:amenities].reject(&:empty?)
  end

end
