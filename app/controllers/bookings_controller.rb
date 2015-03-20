class BookingsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include BookingsHelper
  before_action :authenticate_user!

  def paid_bookings
    retrieve_bookings([], 'retrieve_bookings')
  end

  def venue_paid_bookings
    venue_ids = []
    if Venue.exists?(params[:venue_id].to_i)
      @venue_id = params[:venue_id]
      venue_ids.push(@venue_id)
    end
    @venues = current_represented.venues
    retrieve_bookings(venue_ids, 'retrieve_bookings_venues')
  end

  def destroy
    booking = Booking.find(params[:id])
    return render_forbidden unless BookingContext.new(current_represented, []).delete(booking)
    redirect_to paid_bookings_bookings_path
  end

  private

  def retrieve_bookings(venue_ids, method_name)
    booking_context = BookingContext.new(current_represented, venue_ids)
    @paid = booking_context.send(method_name, Booking.states.values_at(:paid))
    @canceled = booking_context.send(method_name, Booking.states.values_at(:canceled))
  end

end
