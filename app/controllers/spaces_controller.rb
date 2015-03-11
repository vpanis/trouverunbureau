class SpacesController < ModelController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!

  def new
    @venue = Venue.find_by(id: params[:id])
    @space = Space.new(venue: @venue)
    @space_types_options = Space.s_types.map { |t| [t("spaces.types.#{t.first}"), t.first] }
  end

  def create
    space = Space.create!(space_params)
    redirect_to edit_space_path(space)
  end

  def edit
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?
    return render nothing: true, status: 403 unless SpaceContext.new(@space, current_represented)
                                                                .owner?
    @space_types_options = Space.s_types.map { |t| [t("spaces.types.#{t.first}"), t.first] }
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
