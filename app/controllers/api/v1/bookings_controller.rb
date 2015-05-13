module Api
  module V1
    class BookingsController < ApplicationController
      include RepresentedHelper
      include ArraySerializerHelper

      before_action :authenticate_user!
      before_action :retrieve_booking, only: [:accept, :cancel, :deny]

      # PUT /inquiries/:id/accept
      def accept
        state_change(Booking.states[:pending_payment])
      end

      # PUT /inquiries/:id/cancel
      def cancel
        cancellations(Booking.states[:cancelled])
      end

      # PUT /inquiries/:id/deny
      def deny
        cancellations(Booking.states[:denied])
      end

      # PUT /inquiries/:id/edit
      def update_booking
        params[:price] = params[:price].to_i
        return render status: 400, json: { error: 'Invalid price' } if params[:price] <= 0
        @booking = Booking.find_by_id(params[:id])
        @booking, errors = BookingManager.update_booking(current_user, @booking, booking_params)
        return render status: 400, json: { error: @booking.errors.to_a + errors.to_a } if
          !@booking.valid? || !errors.empty?
        render nothing: true, status: 200
      end

      private

      def cancellations(booking_state)
        return state_change(booking_state) unless @booking.paid?
        state_change(Booking.states[:refunding])
        Payments::CancellationWorker.perform_async(@booking.id, current_user.id,
                                                   current_represented.id,
                                                   current_represented.class.to_s) if
            @booking.valid? && @custom_errors.empty?
      end

      def state_change(state)
        return unless inquiry_data_validation(@booking)
        @booking, @custom_errors = BookingManager.change_booking_status(current_user, @booking,
                                                                        state)
        return render status: 400, json: { error: @booking.errors.to_a + @custom_errors.to_a } if
          !@booking.valid? || !@custom_errors.empty?
        render status: 201, nothing: true
      end

      def booking_params
        params.permit(:price)
      end

      def retrieve_booking
        @booking = Booking.find_by_id(params[:id])
      end

      def inquiry_data_validation(booking)
        unless booking.present?
          render json: { error: 'Invalid inquiry' }, status: 400
          return false
        end
        if booking.owner != current_represented && booking.space.venue.owner != current_represented
          render status: 403, nothing: true
          return false
        end
        true
      end
    end
  end
end
