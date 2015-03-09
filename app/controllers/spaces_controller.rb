class SpacesController < ModelController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!

  def edit
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?
    return render nothing: true, status: 403 unless SpaceContext.new(@space, current_represented)
                                                                .owner?
    @space_types_options = Space.s_types.map { |t| [t("spaces.types.#{t.first}"), t.last] }
  end

  def update
    do_update(Space, SpaceContext, 'owner?', 'update_space')
  end

  def add_photo
    venue_photo = VenuePhoto.create!(params.permit(:venue_id, :space_id, :photo))
    render json: {id: venue_photo.id, photo: venue_photo.photo.url}, status: 201
  end

  def wishlist
    @current_user = current_user
  end

  private

  def object_params
    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price)
  end
end
