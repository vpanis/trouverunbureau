class VenuesController < ApplicationController
  inherit_resources
  include SelectOptionsHelper
  before_action :authenticate_user!, except: [:show]

  def edit
    @venue = Venue.find(params[:id])
    return unless can_edit?
    options
  end

  def new
    @venue = Venue.new
    @countries_options = countries_options
  end

  def create
    venue = Venue.create(new_venue_params)
    venue.update_attributes!(owner: current_represented, email: current_represented.email)
    TimeZoneRetrieverWorker.perform_async(venue.id) if venue.latitude.present? &&
                                                       venue.longitude.present?
    redirect_to edit_venue_path(venue)
  end

  def update
    @venue = VenueFirstStepEdition.new(Venue.find(params[:id]))
    return unless can_edit?
    @venue.assign_attributes(edit_venue_params)
    if @venue.valid?
      update_venue
    else
      options
      render action: :edit
    end
  end

  def photos
    @venue = Venue.find(params[:id])
    return unless can_edit?
  end

  def spaces
    @venue = Venue.find(params[:id])
    return unless can_edit?
  end

  def show
    @venue = Venue.find(params[:id])
    @user = current_represented
    @photos = @venue.photos
    @selected_space = Space.find(params[:space_id]) if params[:space_id]

    venue_type_category = t("venues.types.#{@venue.v_type}")
    venue_location = "#{@venue.town}, #{Country.new(@venue.country_code).name}"

    set_meta_tags title: t('meta.venues.index.title', name: @venue.name, category: venue_type_category),
                  description: t('meta.venues.index.description', name: @venue.name, category: venue_type_category, location: venue_location)

    # favorites of the user
    if current_user.present?
      @favorite_spaces_ids = current_user.favorite_spaces.pluck(:id)
    else
      @favorite_spaces_ids = []
    end
  end

  def index
    @venues = current_represented.venues
  end

  def publish
    @venue = Venue.find(params[:id])
    redirect_to edit_venue_path(@venue) unless @venue.valid?
    @venue.update_attributes!(status: Venue.statuses[:active])
    redirect_to venue_path(@venue)
  end

  private

  def update_venue
    lat_lon_changed = @venue.latitude_changed? || @venue.longitude_changed?
    @venue.save!
    TimeZoneRetrieverWorker.perform_async(@venue.id) if lat_lon_changed
    redirect_to details_venue_path(@venue)
  end

  def options
    @countries_options = countries_options
    @v_types_options = venue_types_options
    @currency_options = currency_options
  end

  def can_edit?
    return true if VenueContext.new(@venue, current_represented).owner?
    render_forbidden
    false
  end

  def object_params
    params.require(:venue).permit(:town, :street, :postal_code, :phone, :email, :website,
                                  :latitude, :longitude, :name, :description, :currency, :v_type,
                                  :space, :space_unit, :floors, :rooms, :desks, :vat_tax_rate,
                                  :amenities, :rating, :professions, :country_code,
                                  day_hours_attributes: [:id, :from, :to, :weekday, :_destroy])
  end

  def new_venue_params
    params.require(:venue).permit(:name, :country_code, :logo, :force_submit)
  end

  def edit_venue_params
    params.require(:venue).permit(:name, :street, :country_code, :town, :postal_code, :email,
                                  :phone, :v_type, :currency, :latitude, :longitude, :logo,
                                  :force_submit_upd)
  end
end
