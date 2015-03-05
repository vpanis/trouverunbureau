class PaymentsController < ApplicationController
  include RepresentedHelper
  before_action :authenticate_user!

  # GET /payments/new?booking_id
  def new
    @booking = Booking.where(id: params[:booking_id],
                             state: Booking.states[:pending_payment],
                             owner: current_represented).first
    # TODO: custom 404 page
    redirect_to root_path unless @booking.present?
  end

  # POST /payments
  def create
    @booking = Booking.where(id: params[:booking_id],
                             state: Booking.states[:pending_payment],
                             owner: current_represented).first
    # TODO: custom 404 page
    redirect_to root_path unless @booking.present?
    send("payment_#{mode}")
    BookingManager.change_booking_status(current_user, @booking,
                                         Booking.states[:payment_verification])
  end

  private

  def payment_braintree
    render status: 400, json: { error: 'invalid token' } if params[:payment_method_nonce].present?

    Resque.enqueue(BraintreePaymentJob, booking.id, params[:payment_method_nonce], current_user.id,
                   current_represented.id, current_represented.type)
  end
end
