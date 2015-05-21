class ReviewsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!

  def new_client_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_client_review?
    @review = ClientReview.new(booking: @booking)
  end

  # TODO: redirect to bookings or inbox
  def create_client_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_client_review?
    review = ClientReview.create(client_review_params)
    review.booking = @booking
    review.save!
    redirect_to user_path(current_represented)
  end

  def new_venue_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_venue_review?
    @review = VenueReview.new(booking: @booking)
  end

  # TODO: redirect to bookings or inbox
  def create_venue_review
    @booking = Booking.find(params[:id])
    return render_forbidden unless can_do_venue_review?
    review = VenueReview.create(venue_review_params)
    review.booking = @booking
    review.save!
    redirect_to user_path(current_represented)
  end

  private

  def client_review_params
    params.require(:client_review).permit(:stars, :message)
  end

  def venue_review_params
    params.require(:venue_review).permit(:stars, :message)
  end

  def can_do_client_review?
    current_represented.eql?(@booking.space.venue.owner) &&
      @booking.space.venue.time_zone.from_zone_to_utc(@booking.from) < Time.current &&
      @booking.paid? && ClientReview.where(booking: @booking).empty?
  end

  def can_do_venue_review?
    current_represented.eql?(@booking.owner) &&
      @booking.space.venue.time_zone.from_zone_to_utc(@booking.from) < Time.current &&
      @booking.paid? && VenueReview.where(booking: @booking).empty?
  end

end
