class VenuesController < ApplicationController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!, only: [:edit, :update]

  def edit
    @venue = Venue.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?

    @modify_day_hours = load_day_hours
    return render nothing: true, status: 403 unless VenueContext.new(@venue, current_represented)
                                                                .owner?
  end

  def update
    @venue = Venue.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?
    venue_context = VenueContext.new(@venue, current_represented)
    return render nothing: true, status: 403 unless venue_context.owner?
    updated = venue_context.update_venue?(venue_params)
    return render nothing: true, status: 412 unless updated
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
                                  :amenities, :rating, :professions, :country,
                                  day_hours_attributes: [:id, :from, :to, :weekday, :_destroy])

  end

  def venue_hour_params
    params.permit(day_from: [], day_to: [])
  end

  def load_day_hours
    day_hours = []
    @venue.day_hours.each do |dh|
      day_hours[dh.weekday] = dh
    end
    (0..6).each do |index|
      day_hours[index] = VenueHour.new unless day_hours[index].present?
    end
    day_hours
  end

end
