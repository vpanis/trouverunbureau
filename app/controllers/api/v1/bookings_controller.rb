module Api
  module V1
    class BookingsController < ApplicationController
      include ArraySerializerHelper

      before_action :authenticate_user!
      before_action :retrieve_booking, only: [:accept, :cancel, :deny]

      # PUT /inquiries/:id/accept
      def accept
        approve_booking
        render_booking_error
      end

      # PUT /inquiries/:id/cancel
      def cancel
        cancellation(Booking.states[:cancelled])
      end

      # PUT /inquiries/:id/deny
      def deny
        cancellation(Booking.states[:denied])
      end

      # PUT /inquiries/:id/edit
      def update_booking
        params[:price] = params[:price].to_i
        return render status: 400, json: { error: 'Invalid price' } if params[:price] <= 0
        @booking = Booking.find_by_id(params[:id])
        @booking, errors = BookingManager.update_booking(current_user, @booking, booking_params)

        approve_booking

        return render status: 400, json: { error: @booking.errors.to_a + errors.to_a } if
          !@booking.valid? || !errors.empty?
        render nothing: true, status: 200
      end

      private

      def approve_booking
        state = Booking.states[:pending_payment]
        @booking, @custom_errors = BookingManager.change_booking_status(current_user,
                                                                        @booking,
                                                                        state)
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

      def cancellation(state)
        return unless inquiry_data_validation(@booking)
        @booking, @custom_errors = BookingManager.cancellations(state,
                                                                @booking,
                                                                current_represented,
                                                                current_user)
        render_booking_error
      end

      def booking_params
        params.permit(:price)
      end

      def retrieve_booking
        @booking = Booking.find(params[:id])
      end

      def render_booking_error
        return render status: 400, json: { error: @booking.errors.to_a + @custom_errors.to_a } if
          !@booking.valid? || !@custom_errors.empty?
        render status: 201, nothing: true
      end

    end
  end
end
