class VenuesController < ApplicationController
  inherit_resources

  def edit
    @venue = Venue.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?

  end

  def update
    @venue = Venue.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?
    return render nothing: true, status: 404 unless @venue.can_update(venue_params)
    @venue.update_attributes(venue_params)
    redirect_to edit_venue_path(@venue)
  end

  def show
    @venue = Venue.find(params[:id])
    @user = User.first
    @photos = @venue.photos
    @selected_space = Space.find(params[:space_id]) if params[:space_id]
    @favorite_spaces_ids = @user.favorite_spaces.pluck(:id)
  end

  private

  def venue_params
    params.require(:venue).permit(:town, :street, :postal_code, :phone, :email, :website,
                                  :latitude, :longitude, :name, :description, :currency, :v_type,
                                  :space, :space_unit, :floors, :rooms, :desks, :vat_tax_rate,
                                  :amenities, :rating, :professions, :country)
  end

end
