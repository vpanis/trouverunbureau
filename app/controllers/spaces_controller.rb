class SpacesController < ModelController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper
  before_action :authenticate_user!

  def new
    @venue = Venue.find_by(id: params[:id])
    @space = Space.new(venue: @venue)
    @space_types_options = space_types_options
  end

  def create
    space = Space.create!(space_params)
    redirect_to edit_space_path(space)
  end

  def edit
    @space = Space.find(params[:id])
    return render_forbidden unless SpaceContext.new(@space, current_represented).owner?
    @space_types_options = space_types_options
  end

  def update
    do_update(Space, SpaceContext, 'owner?', 'update_space')
  end

  def wishlist
    @current_user = current_user
  end

  def destroy
    space = Space.find(params[:id])
    venue = space.venue
    return render_forbidden unless SpaceContext.new(space, current_represented).owner?
    space.destroy!
    redirect_to spaces_venue_path(venue)
  end

  def index
    @professions = profession_options
    @workspaces = space_types_checkbox_options
  end

  private

  def hour_type_booking
    @from_date = Time.parse(params[:booking][:from] + " " + params[:hour_booking_from])
    @to_date = Time.parse(params[:booking][:from] + " " + params[:hour_booking_to])
    if @to_date.min.in?([0, 30])
      @to_date = @to_date.advance(minutes: -1).at_end_of_minute
    else
      @to_date = @to_date.at_end_of_hour
    end
    @b_type = Booking.b_types[:hour]
  end

  def day_type_booking
    @from_date = Time.parse(params[:booking][:from]).at_beginning_of_day
    @to_date = Time.parse(params[:booking][:to]).at_end_of_day
    @b_type = Booking.b_types[:day]
  end

  def month_type_booking
    @from_date =Time.parse(params[:booking][:from]).at_beginning_of_day
    @to_date =Time.parse(params[:booking][:from]).advance(months: params[:month_quantity]).at_end_of_day
    @b_type = Booking.b_types[:month]
  end

  def book_bla
    BookingManager.book(current_user, { owner: current_represented,
      from: @from_date,
      to: @to_date,
      space_id: params[:id].to_i,
      b_type: Booking.b_types[:month],
      quantity: params[:booking][:quantity] })
  end

  def object_params
    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price, :deposit)
  end

  def space_params
    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description, :deposit,
                                  :hour_price, :day_price, :week_price, :month_price, :venue_id)
  end

end
