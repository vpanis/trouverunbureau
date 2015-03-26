class PaymentsController < ApplicationController
  include RepresentedHelper
  before_action :authenticate_user!

  # GET /payments/new?booking_id
  def new
    @booking = Booking.includes(:payment, space: [:venue])
                 .where(id: params[:booking_id], state: Booking.states[:pending_payment],
                        owner: current_represented).first
    # TODO: custom 404 page
    return redirect_to root_path unless @booking.present?
    @venue = @booking.space.venue
    return unless @venue.collection_account.present? && @venue.collection_account.active?
    @payment_method = which_payment_method(@venue.collection_account)
    payment_requeriments
    @payment = @booking.payment
  end

  # POST /payments
  def create
    @booking = Booking.includes(:payment, space: [:venue])
                 .where(id: params[:booking_id], state: Booking.states[:pending_payment],
                        owner: current_represented).first
    # TODO: custom 404 page
    return redirect_to root_path unless @booking.present?
    @venue = @booking.space.venue
    return unless @venue.collection_account.present? && @venue.collection_account.active?
    @payment_method = which_payment_method(@venue.collection_account)
    return redirect_to root_path if @payment_method == 'invalid_collection_account' ||
      !send("payment_#{@payment_method}_verification")
    pay_if_its_possible
  end

  private

  def payment_requeriments
    case @payment_method
    when 'mangopay'
      return redirect_to root_path unless payment_mangopay_verification
      mangopay_payment
    when 'braintree'
      braintree_payment_and_nonce
    end
  end

  def mangopay_payment
    unless @booking.payment.present?
      @booking.payment = MangopayPayment.new
      @booking.save
    end
    @payment_account = current_represented.mangopay_payment_account
  end

  def braintree_payment_and_nonce
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

  def payment_mangopay_verification
    current_represented.mangopay_payment_account.present? &&
      current_represented.mangopay_payment_account.accepted?
  end

  def payment_mangopay
    BraintreePaymentWorker.perform_async(@booking.id, params[:payment_method_nonce],
                                         current_user.id, current_represented.id,
                                         current_represented.class.to_s)
  end

  def which_payment_method(collection_account)
    case collection_account.class.to_s
    when 'BraintreeCollectionAccount'
      'braintree'
    when 'MangopayCollectionAccount'
      'mangopay'
    else
      'invalid_collection_account'
    end
  end
end
