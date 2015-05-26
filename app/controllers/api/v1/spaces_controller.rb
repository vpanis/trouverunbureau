module Api
  module V1
    class SpacesController < ApiController

      def index
        result = SpaceQuery.new.all(pagination_params, filter_conditions)
        favorites_ids = []
        favorites_ids = current_user.favorite_space_ids if current_user.present?
        render_result(result, serialized_reviews(result, SpaceSerializer, favorites_ids))
      end

      private

      def filter_conditions
        filters = {}
        params.each do |key, value|
          filters.update(key => value) if filter_parameter?(key, value)
        end
        filters.merge(venue_states: [Venue.statuses[:active]])
      end

      def filter_parameter?(param, value)
        filter_parameters = %w(capacity_min capacity_max quantity latitude_from latitude_to
                               longitude_from longitude_to space_types venue_types
                               venue_amenities venue_professions weekday date)
        param.in?(filter_parameters) && (value.is_a?(Array) || !value.strip.blank?)
      end

    end
  end
end
