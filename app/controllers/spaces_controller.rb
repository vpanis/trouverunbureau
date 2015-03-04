class SpacesController < ModelController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!

  def edit
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?
    return render nothing: true, status: 403 unless SpaceContext.new(@space, current_represented)
                                                                .owner?

  end

  def update
    do_update(Space, SpaceContext, 'owner?', 'update_space?')
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
