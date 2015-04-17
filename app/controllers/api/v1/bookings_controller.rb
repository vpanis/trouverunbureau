module Api
  module V1
    class BookingsController < ApplicationController
      include RepresentedHelper
      include ArraySerializerHelper

      before_action :authenticate_user!

      # PUT /inquiries/:id/accept
      def accept
        state_change(Booking.states[:pending_payment])
      end

      # PUT /inquiries/:id/cancel
      def cancel
        state_change(Booking.states[:canceled])
      end

      # PUT /inquiries/:id/deny
      def deny
        state_change(Booking.states[:denied])
      end

      # PUT /inquiries/:id/edit
      def update_booking
        params[:price] = params[:price].to_i
        return render status: 400, json: { error: 'Invalid price' } if params[:price] <= 0
        @booking = Booking.find_by_id(params[:id])
        booking, errors = BookingManager.update_booking(current_user, @booking, booking_params)
        return render status: 400, json: { error: booking.errors.to_a + errors.to_a } if
          !booking.valid? || !errors.empty?
        render nothing: true, status: 200
      end

      private

      def state_change(state)
        booking = Booking.find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        booking, errors = BookingManager.change_booking_status(current_user, booking, state)
        return render status: 400, json: { error: booking.errors.to_a + errors.to_a } if
          !booking.valid? || !errors.empty?
        render status: 201, nothing: true
      end

      def booking_params
        params.permit(:price)
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
