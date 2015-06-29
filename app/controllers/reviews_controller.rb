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
    current_represented.eql?(@booking.space.venue.owner) &&
      @booking.space.venue.time_zone.from_zone_to_utc(@booking.from) < Time.current &&
      @booking.paid?
  end

  def can_do_venue_review?
    current_represented.eql?(@booking.owner) &&
      @booking.space.venue.time_zone.from_zone_to_utc(@booking.from) < Time.current &&
      @booking.paid?
  end

end
