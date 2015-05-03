class PaymentsController < ApplicationController
  include RepresentedHelper
  include SelectOptionsHelper
  before_action :authenticate_user!

  # GET /payments/new?booking_id
  def new
    @booking = Booking.includes(:payment, space: [:venue])
                 .where(id: params[:booking_id], owner: current_represented).first
    return record_not_found unless booking_is_payable?
    @venue = @booking.space.venue
    return redirect_to inbox_user_path(@current_represented) unless
      active_collection_account?(@venue.collection_account)
    @payment_method = which_payment_method(@venue.collection_account)
    payment_requeriments
  end

  # POST /payments
  def create
    @booking = Booking.includes(:payment, space: [:venue])
                 .where(id: params[:booking_id], owner: current_represented).first
    return record_not_found unless @booking.present? && @booking.pending_payment?
    @venue = @booking.space.venue
    return redirect_to inbox_user_path(@current_represented) unless
      active_collection_account?(@venue.collection_account)
    @payment_method = which_payment_method(@venue.collection_account)
    return redirect_to root_path if @payment_method == 'invalid_collection_account' ||
      !send("payment_#{@payment_method}_verification")
    pay_if_its_possible
  end

  private

  def payment_requeriments
    case @payment_method
    when 'mangopay'
      @payment = @booking.payment
      return redirect_to root_path unless payment_mangopay_verification?
      mangopay_payment
    when 'braintree'
      braintree_payment_and_nonce
    end
  end

  def mangopay_payment
    @payment_account = current_represented.mangopay_payment_account
  end

  def braintree_payment_and_nonce
    unless @booking.payment.present?
      @booking.payment = BraintreePayment.new
      @booking.save
    end
    Payments::Braintree::TokenGenerationWorker.perform_async(current_represented.id,
                                                             current_represented.class.to_s,
                                                             @booking.payment.id)
    @payment = @booking.payment
  end

  def pay_if_its_possible
    @booking, custom_errors = BookingManager.change_booking_status(
                                current_user, @booking, Booking.states[:payment_verification])
    # Error handling for collition in booking
    return redirect_to root_path unless @booking.valid? && custom_errors.empty?
    send("payment_#{@payment_method}")
    redirect_to inbox_user_path(@current_represented)
  end

  def payment_braintree_verification
    params[:payment_method_nonce].present?
  end

  def payment_braintree
    Payments::Braintree::PaymentWorker.perform_async(@booking.id, params[:payment_method_nonce],
                                                     current_user.id, current_represented.id,
                                                     current_represented.class.to_s)
  end

  def payment_mangopay_verification?
    current_represented.mangopay_payment_account.present? &&
      current_represented.mangopay_payment_account.accepted? && (@booking.pending_payment? ||
        @payment.present? && (@payment.payin_created? || @payment.expecting_response?))
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

  def active_collection_account?(collection_account)
    collection_account.present? && collection_account.active?
  end

  def booking_is_payable?
    # mangopay can continue a started payment
    @booking.present? && (@booking.pending_payment? || @booking.payment_verification?)
  end
end
