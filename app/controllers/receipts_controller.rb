class ReceiptsController < ApplicationController
  include RepresentedHelper
  before_action :authenticate_user!

  def show
    @booking = Booking.includes(payment: [:receipt, mangopay_payouts: [:receipt]], space: [:venue])
                      .find(params[:id])
    return render_forbidden unless can_see?
    @payment = @booking.payment
    calculate_lists
  end

  private

  def can_see?
    @booking.payment.payin_succeeded? && (@booking.owner == current_represented ||
      @booking.space.venue.owner == current_represented)
  end

  def calculate_lists
    @refunds = []
    @payouts_to_user = []
    @payment.mangopay_payouts.each do |mp|
      return unless mp.transaction_succeeded?
      return @refunds << mp if mp.refund?
      @payouts_to_user << mp
    end
  end
end
