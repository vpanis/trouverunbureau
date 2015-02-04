module Api
  class ReviewsController < ApplicationController
    include ParametersHelper
    respond_to :json

    def reviews
      return render nothing: true, status: 404 unless Venue.find_by(id: params[:id]).present?
      result = PaginatedReviewsQuery.new(params[:id]).reviews(pagination_params)
      render json: { count: result.total_entries, current_page: result.current_page,
                     items_per_page: result.per_page,
                     reviews: serialized_reviews(result) },
             status: 200
    end

    def serialized_reviews(result)
      ActiveModel::ArraySerializer.new(result, each_serializer: ReviewSerializer)
    end

  end
end
