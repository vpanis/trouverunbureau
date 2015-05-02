class SpacesController < ModelController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper
  before_action :authenticate_user!, except: [:index, :search_mobile]

  def new
    @venue = Venue.find(params[:id])
    return render_forbidden unless VenueContext.new(@venue, current_represented).owner?
    @space = Space.new(venue: @venue)
    @space_types_options = space_types_options
    @previous_page = session[:previous_url]
  end

  def create
    space = Space.create!(space_params)
    redirect_to edit_space_path(space, previous_page: params[:previous_page])
  end

  def edit
    @space = Space.find(params[:id])
    return render_forbidden unless SpaceContext.new(@space, current_represented).owner?
    @space_types_options = space_types_options
    @previous_page = params[:previous_page] || session[:previous_url] || edit_space_path(@space)
  end

  def update
    @space = Space.find(params[:id])
    context = SpaceContext.new(@space, current_represented)
    @previous_page = params[:previous_page] || edit_space_path(@space)
    return render_forbidden unless context.owner?
    return redirect_to @previous_page if context.update_space(space_params)
    redirect_to edit_space_path(@space)
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

  def search_mobile
    @space_types_options = space_types_index_options
  end

  private

  def space_params
    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description, :deposit,
                                  :hour_price, :day_price, :week_price, :month_price, :venue_id)
  end
end
