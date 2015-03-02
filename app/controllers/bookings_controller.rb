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

  private

  def retrieve_bookings(venue_books)
    booking_context = BookingContext.new(current_represented)
    method_name = (venue_books) ? 'retrieve_bookings_venues' : 'retrieve_bookings'
    @paid = booking_context.send(method_name, Booking.states.values_at(:paid))
    @canceled = booking_context.send(method_name, Booking.states.values_at(:canceled))
  end
end
