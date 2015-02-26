class BookingsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  before_action :authenticate_user!

  def paid_bookings
    booking_context = BookingContext.new(current_represented)
    @paid = booking_context.retrieve_state_bookings(Booking.states.values_at(:paid))
    @canceled = booking_context.retrieve_state_bookings(Booking.states.values_at(:canceled))
  end
end
