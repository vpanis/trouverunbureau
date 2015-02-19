module Api
  module V1
    class BookingInquiriesController < ApplicationController
      include RepresentedHelper
      include ArraySerializerHelper

      before_action :authenticate_user!

      # We will be using the current_represented, but we ask this data
      # for future cache reasons
      # GET /represented/:id/inquiries?type=[User|Organization]
      def inquiries
        return unless represented_data_validation
        render status: 200, json: serialized_paginated_array(Booking.all_bookings_for(
          current_represented), :inquiries, InquirySerializer)
      end

      # PUT /inquiries/:id/last_seen_message?message_id
      def last_seen_message
        booking = Booking.find_by_id(params[:id]).includes(:owner, space: { venue: :owner })
        return unless inquiry_data_validation(booking)
        message = Message.where(id: params[:message_id], booking_id: params[:id])
        return render json: { error: 'Invalid message' }, status: 400 unless message.present?

        BookingManager.change_last_seen(booking, current_represented, message.created_at)

        render status: 204, nothing: true
      end

      # GET /represented/:id/inquiries?type=[User|Organization]
      def inqueries_with_news
        return unless represented_data_validation
        BookingManager.bookings_with_news(current_represented)
        render status: 200, json: serialized_paginated_array(BookingManager.bookings_with_news(
          current_represented), :inquiries, InquirySerializer)
      end

      # POST /inquiry/:id/messages
      def add_message
        booking = Booking.find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        params[:message][:m_type] = Message.m_types[:text]
        params[:message][:user] = current_user
        params[:message][:represented] = current_represented
        params[:message][:booking_id] = params[:id]
        message = Message.new(message_params)
        return render status: 400, json: { error: message.errors } unless message.valid?
        message.save
        render status: 200, json: MessageSerializer.new(message)
      end

      # GET /inquiry/:id/messages[?from=x&to=x&amount=x&page=x]
      def messages
        booking = Booking.find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        convert_strings_to_dates(:from, :to)
        messages = booking.messages
        messages = messages.where { created_at >= params[:from] } if params[:from]
        messages = messages.where { created_at <= params[:to] } if params[:to]
        messages = messages.order('created_at DESC')
        render status: 200, json: serialized_paginated_array(messages, :inquiries,
                                                             MessageSerializer)
      end

      # PUT /inquiry/:id/accept
      def accept
        state_change(Booking.states[:pending_payment])
      end

      # PUT /inquiry/:id/cancel
      def cancel
        state_change(Booking.states[:canceled])
      end

      # PUT /inquiry/:id/deny
      def deny
        state_change(Booking.states[:denied])
      end

      private

      def state_change(state)
        booking = Booking.find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        booking, errors = change_booking_status(current_user, booking, state)
        return render status: 400, json: { error: booking.errors + errors } if !booking.valid? ||
          !errors.empty?
        render status: 201, nothing: true
      end

      def represented_data_validation
        unless %w(User Organization).include?(params[:type])
          render status: 400, json: { error: 'Invalid type' }
          return false
        end
        if params[:id] != current_represented.id
          render status: 403, nothing: true
          return false
        end
        true
      end

      def inquiry_data_validation(booking)
        unless booking.present?
          render json: { error: 'Invalid inquiry' }, status: 400
          return false
        end
        if booking.owner != current_represented || booking.space.venue.owner != current_represented
          render status: 403, nothing: true
          return false
        end
        true
      end

      def message_params
        params.require(:message).permit(:text, :user, :represented, :booking_id, :m_type)
      end
    end
  end
end
