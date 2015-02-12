module Api
  module V1
    class SpaceController < ApplicationController
      include ParametersHelper
      respond_to :json
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def list
        result = SpaceQuery.new.all(pagination_params, filter_conditions)
        favorites_ids = []
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       spaces: serialized_reviews(result, SpaceSerializer, favorites_ids) },
               status: 200
      end

      def filter_conditions
        filters = {}
        params.each do |key, value|
          filters.update(key => value) if filter_parameter?(key, value)
        end
        filters
      end

      def filter_parameter?(param, value)
        filter_parameters = %w(capacity, quantity, latitude_from, latitude_to,
                               longitude_from, longitude_to, space_types, venue_types,
                               venue_amenities, venue_professions, weekday)
        param.in?(filter_parameters) && !value.strip.blank?
      end

      def serialized_reviews(result, serializer, ids)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer,
                                                 scope: { favorites_ids: ids })
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
