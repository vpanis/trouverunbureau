class PaymentsController < ApplicationController
  include RepresentedHelper
  before_action :authenticate_user!

  # GET /payments/new?booking_id
  def new
    @booking = Booking.where(id: params[:booking_id],
                             owner: current_represented).first
                             # state: Booking.states[:pending_payment], REMOVE FOR TESTING
    # TODO: custom 404 page
    redirect_to root_path unless @booking.present?
  end

  # POST /payments
  def create
    @booking = Booking.where(id: params[:booking_id],
                             state: Booking.states[:pending_payment],
                             owner: current_represented).first
    # TODO: custom 404 page
    redirect_to root_path unless @booking.present? && params[:mode].in?(%w(braintree))
    send("payment_#{params[:mode]}")
    BookingManager.change_booking_status(current_user, @booking,
                                         Booking.states[:payment_verification])
    redirect_to new_payment_path(booking_id: @booking.id) && return
  end

  private

  def payment_braintree
    render status: 400, json: { error: 'invalid token' } if params[:payment_method_nonce].present?

    unless @booking.payment.present?
      @booking.payment = BraintreePayment.new
      @booking.save
    end
    Resque.enqueue(BraintreePaymentJob, @booking.id, params[:payment_method_nonce],
                   current_user.id, current_represented.id, current_represented.class.to_s)
  end
end
