module Api
  module V1
    class SpaceController < ListController
      include ParametersHelper
      respond_to :json
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def list
        result = SpaceQuery.new.all(pagination_params, filter_conditions)
        favorites_ids = []
        render_result(result, serialized_reviews(result, SpaceSerializer, favorites_ids))
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

    end
  end
end
