module Api
  class ReviewsController < ApplicationController
      include ParametersHelper
      respond_to :json

      def reviews
        result=PaginatedReviewsQuery.new(params[:id]).reviews(pagination_params)
        # byebug
        render json: result, each_serializer: ReviewSerializer
      end

  end
end
