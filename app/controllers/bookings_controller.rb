class BookingsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include BookingsHelper
  before_action :authenticate_user!

  def paid_bookings
    retrieve_bookings([], 'retrieve_bookings')
  end

  def venue_paid_bookings
    @venue_id = Venue.find_by(id: params[:venue_id]).id if params[:venue_id].present?
    @venues = current_represented.venues
    venue_ids = @venue_id.present? ? [@venue_id] : []
    retrieve_bookings(venue_ids, 'retrieve_bookings_venues')
  end

  def destroy
    booking = Booking.find_by(id: params[:id])
    return render nothing: true, status: 404 unless booking.present?
    return render nothing: true, status: 403 unless BookingContext.new(current_represented, [])
                                                                  .delete(booking)
    redirect_to paid_bookings_bookings_path
  end

  private

  def retrieve_bookings(venue_ids, method_name)
    booking_context = BookingContext.new(current_represented, venue_ids)
    @paid = booking_context.send(method_name, Booking.states.values_at(:paid))
    @canceled = booking_context.send(method_name, Booking.states.values_at(:canceled))
  end
end
