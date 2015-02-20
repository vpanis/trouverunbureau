class SpacesController < ApplicationController
  inherit_resources
  before_action :authenticate_user!, only: [:edit, :update]

  def edit
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?
    return render nothing: true, status: 403 unless SpaceContext.new(@space, current_user)
                                                                .permissions?

  end

  def update
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?
    space_context = SpaceContext.new(@space, current_user)
    return render nothing: true, status: 403 unless space_context.permissions?
    return render nothing: true, status: 412 unless space_context.update?(space_params)
    redirect_to edit_space_path(@space)
  end

  private

  def space_params

    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price)
  end

end
