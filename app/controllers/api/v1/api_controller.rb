module Api
  module V1
    class ApiController < ApplicationController
      include ParametersHelper
      include RepresentedHelper
      respond_to :json

      def render_result(result, serialized_array)
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       spaces: serialized_array },
               status: 200
      end

      def serialized_reviews(result, serializer, ids)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer,
                                                 scope: { favorites_ids: ids })
      end

      def record_not_found
        render status: 404, nothing: true
      end

      def forbidden
        render status: 403, nothing: true
      end

      def wrong_preconditions
        render status: 412, nothing: true
      end

      def render_nothing
        render status: 204, nothing: true
      end

    end
  end
end
