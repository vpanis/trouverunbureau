module Api
  module V1
    class ReviewsController < ApplicationController
      include ParametersHelper
      respond_to :json

      def venue_reviews
        do_action(params[:id], Venue, 'venue_reviews', VenueReviewSerializer)

      end

      def client_reviews
        do_action(params[:id], User, 'client_reviews', ClientReviewSerializer)

      end

      def do_action(id, entity, method, serializer)
        return render nothing: true, status: 404 unless entity.find_by(id: id).present?
        result = PaginatedReviewsQuery.new.send(method, pagination_params, id)
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       reviews: serialized_reviews(result, serializer) },
               status: 200
      end

      def serialized_reviews(result, serializer)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer)
      end

    end
  end
end
