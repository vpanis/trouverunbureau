module Api
  class ReviewsController < ApplicationController
    include ParametersHelper
    respond_to :json

    def venue_reviews
      return render nothing: true, status: 404 unless Venue.find_by(id: params[:id]).present?
      result = PaginatedReviewsQuery.new().venue_reviews(pagination_params, params[:id])
      render json: { count: result.total_entries, current_page: result.current_page,
                     items_per_page: result.per_page,
                     reviews: serialized_venue_reviews(result) },
             status: 200
    end

    def client_reviews
      return render nothing: true, status: 404 unless User.find_by(id: params[:id]).present?
      result = PaginatedReviewsQuery.new().client_reviews(pagination_params,params[:id])
      render json: { count: result.total_entries, current_page: result.current_page,
                     items_per_page: result.per_page,
                     reviews: serialized_client_reviews(result) },
             status: 200
    end

    def serialized_venue_reviews(result)
      ActiveModel::ArraySerializer.new(result, each_serializer: ReviewSerializer, root: false)
    end

    def serialized_client_reviews(result)
      ActiveModel::ArraySerializer.new(result, each_serializer: ClientReviewSerializer, root: false)
    end
  end
end
