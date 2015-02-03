module Api
  class ReviewsController < ApplicationController
    include ParametersHelper
    respond_to :json

    def reviews
      venue=Venue.find(params[:id])
      result = PaginatedReviewsQuery.new(params[:id]).reviews(pagination_params)
      byebug
      render json: result, each_serializer: ReviewSerializer, status: 200
    rescue Exception => e
      byebug
      render json: "404", status: 404
    end

  end
end
