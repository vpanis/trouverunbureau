module Api
  module V1
    class SpaceController < ApplicationController
      include ParametersHelper
      respond_to :json
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def list
        # return render nothing: true, status: 404 unless User.find_by(id: params[:id]).present?
        result = SpaceQuery.new.all(pagination_params, filter_conditions)
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       spaces: serialized_reviews(result, SpaceSerializer) },
               status: 200
      end

      def filter_conditions
        filters = Hash.new
        params.each do |p|

        end
        filters
      end

      def serialized_reviews(result, serializer)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer)
      end

      def record_not_found
        render status: 404, nothing: true
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
