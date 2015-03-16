class PaymentsController < ApplicationController
  include RepresentedHelper
  before_action :authenticate_user!

  # GET /payments/new?booking_id
  def new
    @booking = Booking.where(id: params[:booking_id],
                             state: Booking.states[:pending_payment], # REMOVE FOR TESTING
                             owner: current_represented).first
    # TODO: custom 404 page
    return redirect_to root_path unless @booking.present? &&
      @booking.collection_account.present? && @booking.collection_account.active?
    generate_nonce_for_payment
    @payment = @booking.payment
  end

  # POST /payments
  def create
    @booking = Booking.where(id: params[:booking_id], state: Booking.states[:pending_payment],
                             owner: current_represented).first
    # TODO: custom 404 page
    return redirect_to root_path unless @booking.present? && params[:mode].in?(%w(braintree)) &&
      send("payment_#{params[:mode]}_verification")
    pay_if_its_possible
  end

  private

  def generate_nonce_for_payment
    unless @booking.payment.present?
      @booking.payment = BraintreePayment.new
      @booking.save
    end
    BraintreeTokenGenerationWorker.perform_async(current_represented.id,
                                                 current_represented.class.to_s,
                                                 @booking.payment.id)
  end

  def pay_if_its_possible
    @booking, custom_errors = BookingManager.change_booking_status(
                                current_user, @booking, Booking.states[:payment_verification])
    # Error handling for collition in booking
    return redirect_to root_path unless @booking.valid? && custom_errors.empty?
    send("payment_#{params[:mode]}")
    redirect_to new_payment_path(booking_id: @booking.id)
  end

  def payment_braintree_verification
    params[:payment_method_nonce].present?
  end

  def payment_braintree
    BraintreePaymentWorker.perform_async(@booking.id, params[:payment_method_nonce],
                                         current_user.id, current_represented.id,
                                         current_represented.class.to_s)
  end
end
