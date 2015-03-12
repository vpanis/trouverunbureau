class VenuesController < ModelController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!, except: [:show]

  def edit
    @venue = Venue.find(params[:id])
    return unless can_edit?
    @countries_options = Country.all.map { |c| [c.name, c.id] }
    @v_types_options = Venue.v_types.map { |t| [t("venues.types.#{t.first}"), t.first] }
    @currency_options = currency_options
  end

  def new
    @venue = Venue.new
    @countries_options = Country.all.map { |c| [c.name, c.id] }
  end

  # TODO: almost all methods here have been harcoded. implement them!!!!
  def create
    venue = Venue.create(new_venue_params)
    venue.update_attributes(owner: current_represented, email: current_represented.email)
    venue.save!
    redirect_to edit_venue_path(venue)
  end

  def update
    @venue = Venue.find(params[:id])
    return unless can_edit?
    # return render nothing: true, status: 412 unless VenueContext.new(@venue, current_represented)
    #                                                           .update_venue(object_params)
    @venue.update_attributes!(edit_venue_params)
    redirect_to action: 'details'
  end

  def details
    @venue = Venue.find(params[:id])
    @modify_day_hours = load_day_hours
    return unless can_edit?
  end

  def save_details
    @venue = Venue.find(params[:id])
    return unless can_edit?
    @venue.update_attributes!(object_params)
    redirect_to amenities_venue_path(@venue)
  end

  def amenities
    @venue = Venue.find(params[:id])
    return unless can_edit?
  end

  def save_amenities
    @venue = Venue.find(params[:id])
    return unless can_edit?
    @venue.update_attributes!(amenities_params)
    redirect_to photos_venue_path(@venue)
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
    @user = User.first
    @photos = @venue.photos
    @selected_space = Space.find(params[:space_id]) if params[:space_id]
    @favorite_spaces_ids = @user.favorite_spaces.pluck(:id)
  end

  def search
    @current_user = current_user
  end

  private

  def can_edit?
    return true if VenueContext.new(@venue, current_represented).owner?
    render nothing: true, status: 403
    false
  end

  def object_params
    params.require(:venue).permit(:town, :street, :postal_code, :phone, :email, :website,
                                  :latitude, :longitude, :name, :description, :currency, :v_type,
                                  :space, :space_unit, :floors, :rooms, :desks, :vat_tax_rate,
                                  :rating, :professions,
                                  day_hours_attributes: [:id, :from, :to, :weekday, :_destroy])
  end

  def amenities_params
    params.require(:venue).permit(amenities: [])[:amenities].reject!(&:empty?)
  end

  def new_venue_params
    params.require(:venue).permit(:name, :country_id, :force_submit, :logo)
  end

  def edit_venue_params
    params.require(:venue).permit(:name, :street, :country_id, :town, :postal_code, :email,
                                  :phone, :v_type, :currency, :latitude, :longitude)
  end

  def load_day_hours
    day_hours = []
    @venue.day_hours.each do |dh|
      day_hours[dh.weekday] = dh
    end
    (0..6).each do |index|
      day_hours[index] = VenueHour.new(weekday: index) unless day_hours[index].present?
    end
    day_hours
  end

  def currency_options
    # TODO: define currency list
    [[t('currency.usd.long_name'), 'usd'], [t('currency.gbp.long_name'), 'gbp'],
     [t('currency.euro.long_name'), 'eur'], [t('currency.cad.long_name'), 'cad'],
     [t('currency.aud.long_name'), 'aud']]
  end

end
