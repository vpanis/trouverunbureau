class ReviewsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!

  # TODO: implement properly and TEST
  def new_client_review
    @booking = Booking.find(params[:id])
    @review = ClientReview.new(booking: @booking)
  end

  def create_client_review
    @booking = Booking.find(params[:id])
    redirect_to client_review_booking_path(@booking)
  end

  def new_venue_review
    @booking = Booking.find(params[:id])
    @review = VenueReview.new(booking: @booking)
  end

  def create_venue_review
    @booking = Booking.find(params[:id])
    redirect_to venue_review_booking_path(@booking)
  end

end
