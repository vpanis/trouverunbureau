class ReceiptsController < ApplicationController
  before_action :authenticate_user!

  def show
    # TODO: eager loading
    @booking = Booking.includes(:payment, space: [:venue]).find(params[:id])
    return render_forbidden unless can_see?
    @payment = @booking.payment
    calculate_lists
  end

  private

  def can_see?
    @booking.payment.present? && @booking.payment.payin_succeeded? &&
      (@booking.owner == current_represented || @booking.space.venue.owner == current_represented)
  end

  def calculate_lists
    @refunds = []
    @payouts_to_user = []
    @payment.mangopay_payouts.each do |mp|
      @refunds << mp if mp.transaction_succeeded? && mp.refund?
      @payouts_to_user << mp if mp.transaction_succeeded? && mp.payout_to_user?
    end
  end
end
