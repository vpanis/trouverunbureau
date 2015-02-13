class SpacesController < ApplicationController
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
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?
    space_context = SpaceContext.new(@space, current_represented)
    return render nothing: true, status: 403 unless space_context.owner?
    return render nothing: true, status: 412 unless space_context.update_space?(space_params)
    redirect_to edit_space_path(@space)
  end

  private

  def space_params

    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price)
  end
end
