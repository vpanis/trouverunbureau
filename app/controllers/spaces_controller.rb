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

  private

  def object_params
    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price)
  end

  def space_params
    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price, :venue_id)
  end
end
