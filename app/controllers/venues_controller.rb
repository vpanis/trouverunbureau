class VenuesController < ModelController
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
    do_update(Venue, VenueContext, 'owner?', 'update_venue')
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

  def object_params
    params.require(:venue).permit(:town, :street, :postal_code, :phone, :email, :website,
                                  :latitude, :longitude, :name, :description, :currency, :v_type,
                                  :space, :space_unit, :floors, :rooms, :desks, :vat_tax_rate,
                                  :amenities, :rating, :professions, :country,
                                  day_hours_attributes: [:id, :from, :to, :weekday, :_destroy])

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

end
