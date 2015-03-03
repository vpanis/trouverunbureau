class BookingsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include BookingsHelper
  before_action :authenticate_user!

  def paid_bookings
    retrieve_bookings(false)
  end

  def venue_paid_bookings
    retrieve_bookings(true)
  end

  def delete
    booking = Booking.find_by(id: params[:id])
    return render nothing: true, status: 404 unless booking.present?
    return render nothing: true, status: 403 unless BookingContext.new(current_represented, [])
                                                                  .delete(booking)
    redirect_to paid_bookings_bookings_path
  end

  private

  def retrieve_bookings(venue_books)
    venue_ids = (venue_books && params[:venue_ids].present?) ? params[:venue_ids] : []
    booking_context = BookingContext.new(current_represented, venue_ids)
    method_name = (venue_books) ? 'retrieve_bookings_venues' : 'retrieve_bookings'
    @paid = booking_context.send(method_name, Booking.states.values_at(:paid))
    @canceled = booking_context.send(method_name, Booking.states.values_at(:canceled))
    @venues = booking_context.retrieve_bookings_venue_names if venue_books
  end
end
