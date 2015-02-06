module Api
  module V1
    class ReviewsController < ApplicationController
      include ParametersHelper
      respond_to :json

      def venue_reviews
        return render nothing: true, status: 404 unless Venue.find_by(id: params[:id]).present?
        result = PaginatedReviewsQuery.new.venue_reviews(pagination_params, params[:id])
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       reviews: serialized_reviews(result, VenueReviewSerializer) },
               status: 200
      end

      def client_reviews
        return render nothing: true, status: 404 unless User.find_by(id: params[:id]).present?
        result = PaginatedReviewsQuery.new.client_reviews(pagination_params, params[:id])
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       reviews: serialized_reviews(result, ClientReviewSerializer) },
               status: 200
      end

      def serialized_reviews(result, serializer)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer)
      end

    end
  end
end
