module Api
  module V1
    class ReviewsController < ApplicationController
      include ParametersHelper
      respond_to :json
      before_action :something
      # before_action :authenticate_user!, only: [:client_reviews]
      # acts_as_token_authentication_handler_for Organization, only: [:client_reviews],
                                                             # fallback_to_devise: false
      acts_as_token_authentication_handler_for User, only: [:client_reviews]

      def venue_reviews
        do_action(params[:id], Venue, 'venue_reviews', VenueReviewSerializer)
      end

      def client_reviews
        return render nothing: true, status: 404 unless %w(User Organization).include?(
          params[:type])
        do_action(params[:id], Object.const_get(params[:type]), 'client_reviews',
                                                ClientReviewSerializer)
      end

      def do_action(id, entity, review_type, serializer)
        return render nothing: true, status: 404 unless entity.find_by(id: id).present?
        if entity == Venue
          result = PaginatedReviewsQuery.new.send(review_type, pagination_params,id)
        else
          return render nothing: true, status: 403 unless verify_user_can_read_client_reviews
          result = PaginatedReviewsQuery.new.send(review_type, pagination_params,
                                                  id, entity)
        end
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       reviews: serialized_reviews(result, serializer) },
               status: 200
      end

      def serialized_reviews(result, serializer)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer)
      end

      private

      def something
        # binding.pry
      end

      def verify_user_can_read_client_reviews
        venue_owner = current_user
        return true if current_user.id == params[:id].to_i
        # venue_owner = current_organization if current_organization.present?
        !Booking.joins { space.venue }
          .where { (owner_id == my { params[:id] }) & (owner_type == my { params[:type] }) }
          .where { space.venue.owner == my { venue_owner } }.empty?
      end
    end
  end
end
