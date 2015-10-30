class BookingsController < ApplicationController
  inherit_resources
  include BookingsHelper
  before_action :authenticate_user!
  before_action :retrieve_booking, only: [:destroy, :claim_deposit, :cancel_paid_booking]

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
    return render_forbidden unless BookingContext.new(current_represented, []).delete(@booking)
    redirect_to paid_bookings_bookings_path
  end

  def claim_deposit
    return render_forbidden unless can_claim_deposit?(@booking)
    @booking.update_attributes(hold_deposit: true)
    return redirect_to :venue_paid_bookings_bookings if
      params[:from_bookings] == 'venue_paid_bookings'
    redirect_to :paid_bookings_bookings
  end

  def cancel_paid_booking
    return unless inquiry_data_validation(@booking)
    state = get_booking_state(params[:from_cancel])
    @booking, @custom_errors = BookingManager.cancellations(state,
                                                            @booking,
                                                            current_represented,
                                                            current_user)
    redirect_to_bookings
  end

  def get_booking_state(from)
    return Booking.states[:cancelled] if from == 'paid_bookings'
    return Booking.states[:denied] if from == 'venue_paid_bookings'
  end

  def inquiry_data_validation(booking)
    unless booking.present?
      redirect_to :root
      return false
    end
    if booking.owner != current_represented && booking.space.venue.owner != current_represented
      redirect_to :root
      return false
    end
    true
  end

  private

  def retrieve_bookings(venue_ids, method_name)
    booking_context = BookingContext.new(current_represented, venue_ids)
    @paid = booking_context.send(method_name, Booking.states.values_at(:paid))
    @cancelled = booking_context.send(method_name, [Booking.states.values_at(:cancelled),
                                                    Booking.states.values_at(:denied),
                                                    Booking.states.values_at(:refunding),
                                                    Booking.states.values_at(:error_refunding)])
  end

  def retrieve_booking
    @booking = Booking.find(params[:id])
  end

  def redirect_to_bookings
    return redirect_to :root if
      !@booking.valid? || !@custom_errors.empty?
    redirect_to :back
  end

end
