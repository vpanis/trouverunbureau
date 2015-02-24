module Api
  module V1
    class ReviewsController < ApiController
      include RepresentedHelper
      before_action :authenticate_user!, only: [:user_reviews, :organization_reviews]

      def venue_reviews
        do_action(params[:id].to_i, Venue, 'venue_reviews', VenueReviewSerializer)
      end

      def user_reviews
        do_action(params[:id].to_i, User, 'client_reviews', ClientReviewSerializer)
      end

      def organization_reviews
        do_action(params[:id].to_i, Organization, 'client_reviews', ClientReviewSerializer)
      end

      private

      def do_action(id, entity, review_type, serializer)
        return record_not_found unless entity.find_by(id: id).present?
        if entity == Venue
          result = PaginatedReviewsQuery.new.send(review_type, pagination_params, id)
        else
          return forbidden unless user_can_read_client_reviews?(entity, id)
          result = PaginatedReviewsQuery.new.send(review_type, pagination_params, id, entity)
        end
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       reviews: serialized_reviews(result, serializer) }, status: 200
      end

      def serialized_reviews(result, serializer)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer)
      end

    end
  end
end
