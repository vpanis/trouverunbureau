class SpacesController < ApplicationController
  inherit_resources

  def edit
    @space = Space.find(params[:id])
  end

  def update
    @space = Space.find(params[:id])

    @space.update_attributes(space_params) if @space.can_update(space_params)

    redirect_to edit_space_path(@space)
  end

  private

  def space_params

    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description,
                                  :hour_price, :day_price, :week_price, :month_price)
  end

  def affinity_points_params
    params.require(:affinity_points).permit(:c1, :c2, :c3, :c4, :c5, :c6, :c7, :c8, :c9, :c10,
                                            :c11)
  end

end
