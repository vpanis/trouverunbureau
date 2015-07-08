class ReviewsController < ApplicationController
  inherit_resources
  before_action :authenticate_user!

  def new_client_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_client_review?
    return redirect_to venue_paid_bookings_bookings_path if ClientReview.exists?(booking: @booking)
    @review = ClientReview.new(booking: @booking)
  end

  def create_client_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_client_review?
    return redirect_to venue_paid_bookings_bookings_path if ClientReview.exists?(booking: @booking)
    review = ClientReview.create(client_review_params)
    review.booking = @booking
    review.save!
    redirect_to venue_paid_bookings_bookings_path
  end

  def new_venue_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_venue_review?
    return redirect_to paid_bookings_bookings_path if VenueReview.exists?(booking: @booking)
    @review = VenueReview.new(booking: @booking)
  end

  def create_venue_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_venue_review?
    return redirect_to paid_bookings_bookings_path if VenueReview.exists?(booking: @booking)
    review = VenueReview.create(venue_review_params)
    review.booking = @booking
    review.save!
    redirect_to paid_bookings_bookings_path
  end

  private

  def client_review_params
    params.require(:client_review).permit(:stars, :message)
  end

  def venue_review_params
    params.require(:venue_review).permit(:stars, :message)
  end

  def can_do_client_review?
    can_review?(@booking.space.venue.owner)
  end

  def can_do_venue_review?
    can_review?(@booking.owner)
  end

  def can_review?(owner)
    current_represented.eql?(owner) && valid_check_in? && valid_payout?
  end

  def valid_check_in?
    @booking.space.venue.time_zone.from_zone_to_utc(@booking.from) < Time.current
  end

  def valid_payout?
    return false unless @booking.payment.present?
    payout = @booking.payment.mangopay_payouts.first
    payout.present? && payout.payout_to_user?
  end
end
