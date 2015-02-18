class SpacesController < ApplicationController
  inherit_resources

  def edit
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?

  end

  def update
    @space = Space.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @space.present?
    return render nothing: true, status: 412 unless @space.can_update(space_params)
    @space.update_attributes(space_params)
    redirect_to edit_space_path(@space)
  end

  private

  def space_params

    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price)
  end

end
