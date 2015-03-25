module Api
  module V1
    class BookingInquiriesController < ApplicationController
      include RepresentedHelper
      include ArraySerializerHelper

      before_action :authenticate_user!

      # GET /organizations/:id/inquiries
      def organization_inquiries
        params[:entity] = Organization
        inquiries
      end

      # GET /users/:id/inquiries
      def user_inquiries
        params[:entity] = User
        inquiries
      end

      # GET /organizations/:id/inquiries_with_news
      def organization_inquiries_with_news
        params[:entity] = Organization
        inqueries_with_news
      end

      # GET /users/:id/inquiries_with_news
      def user_inquiries_with_news
        params[:entity] = User
        inqueries_with_news
      end

      # PUT /inquiries/:id/last_seen_message?message_id
      def last_seen_message
        booking = Booking.includes(:owner, space: { venue: :owner }).find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        message = Message.where(id: params[:message_id], booking_id: params[:id]).first
        return render json: { error: 'Invalid message' }, status: 400 unless message.present?

        BookingManager.change_last_seen(booking, current_represented, message.created_at)

        render status: 204, nothing: true
      end

      # POST /inquiries/:id/messages
      def add_message
        booking = Booking.find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        message_params = { m_type: Message.m_types[:text], user: current_user,
          represented: current_represented, booking_id: params[:id]
        }
        message_params[:text] = params[:message][:text] if params.include?(:message)
        message = Message.new(message_params)
        return render status: 400, json: { error: message.errors } unless message.valid?
        message.save
        render status: 200, json: MessageSerializer.new(message)
      end

      # GET /inquiries/:id/messages[?from=x&to=x&amount=x&page=x]
      def messages
        booking = Booking.find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        convert_strings_to_dates(:from, :to)
        messages = booking.messages
        messages = messages.where { created_at > my { params[:from] } } if params[:from]
        messages = messages.where { created_at <= my { params[:to] } } if params[:to]
        messages = messages.order('created_at DESC')
        render status: 200, json: serialized_paginated_array(messages, :messages,
                                                             MessageSerializer)
      end

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

      private

      def inquiries
        return unless represented_data_validation
        render status: 200,
               json: serialized_paginated_array(Booking.all_bookings_for(current_represented),
                                                :inquiries, InquirySerializer).as_json
      end

      def inqueries_with_news
        return unless represented_data_validation
        render status: 200, json: serialized_paginated_array(BookingManager.bookings_with_news(
          current_represented), :inquiries, InquirySerializer)
      end

      def state_change(state)
        booking = Booking.find_by_id(params[:id])
        return unless inquiry_data_validation(booking)
        booking, errors = BookingManager.change_booking_status(current_user, booking, state)
        return render status: 400, json: { error: booking.errors.to_a + errors.to_a } if
          !booking.valid? || !errors.empty?
        render status: 201, nothing: true
      end

      def represented_data_validation
        if params[:id].to_i != current_represented.id ||
          params[:entity] != current_represented.class
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
        if booking.owner != current_represented && booking.space.venue.owner != current_represented
          render status: 403, nothing: true
          return false
        end
        true
      end
    end
  end
end
