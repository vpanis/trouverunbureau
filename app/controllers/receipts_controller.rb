class ReceiptsController < ModelController
  include RepresentedHelper
  before_action :authenticate_user!

  def show
    @booking =   Booking.includes(space: [:venue]).find(params[:id])
  end
end
