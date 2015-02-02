module api
  class ReviewsController < ApplicationApiController
    include ParametersHelper
    respond_to :json

    def reviews
      venue = Venue.find(params[:id])
      render json: PaginatedReviewsQuery.new(venue).profile_feed(pagination_params),
             each_serializer: ReviewSerializer
    end

  end
end
