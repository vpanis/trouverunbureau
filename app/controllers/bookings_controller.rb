class BookingsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include BookingsHelper
  before_action :authenticate_user!

  def paid_bookings
    retrieve_bookings([], 'retrieve_bookings')
  end

  def venue_paid_bookings
    venue_ids = params[:venue_ids] || []
    retrieve_bookings(venue_ids, 'retrieve_bookings_venues')
    @venues = BookingContext.new(current_represented, venue_ids).retrieve_bookings_venue_names
  end

  def delete
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
