module Api
  module V1
    class ReviewsController < ApplicationController
      include ParametersHelper
      include RepresentedHelper

      respond_to :json
      before_action :authenticate_user!, only: [:client_reviews]

      def venue_reviews
        do_action(params[:id], Venue, 'venue_reviews', VenueReviewSerializer)
      end

      def client_reviews
        return render 'Invalid type', status: 400 unless %w(User Organization).include?(
          params[:type])
        do_action(params[:id], Object.const_get(params[:type]), 'client_reviews',
                  ClientReviewSerializer)
      end

      private

      def do_action(id, entity, review_type, serializer)
        return render nothing: true, status: 404 unless entity.find_by(id: id).present?
        if entity == Venue
          result = PaginatedReviewsQuery.new.send(review_type, pagination_params, id)
        else
          return render nothing: true, status: 403 unless user_can_read_client_reviews?(entity)
          result = PaginatedReviewsQuery.new.send(review_type, pagination_params, id, entity)
        end
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       reviews: serialized_reviews(result, serializer) }, status: 200
      end

      def serialized_reviews(result, serializer)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer)
      end

      def user_can_read_client_reviews?(entity)
        # Me asking for Me, Me as Org asking for Org, and Me as Org asking for Me
        return true if (current_represented.id == params[:id].to_i &&
          current_represented.class == entity) || (current_user.id == params[:id].to_i &&
          entity == User)
        # My clients
        !Booking.joins { space.venue }
          .where { (owner_id == my { params[:id] }) & (owner_type == my { params[:type] }) }
          .where { space.venue.owner == my { current_represented } }.empty?
      end
    end
  end
end
