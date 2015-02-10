module Api
  module V1
    class WishlistController < ApplicationController
      include ParametersHelper
      respond_to :json
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def wishlist
        return render nothing: true, status: 404 unless User.find_by(id: params[:id]).present?
        result = WishlistQuery.new(params[:id]).wishlist(pagination_params)
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       spaces: serialized_reviews(result, UserFavoriteSerializer) },
               status: 200
      end

      def add_space_to_wishlist
        do_action(params[:id], params[:space_id], 'add_to_wishlist')
      end

      def remove_space_from_wishlist
        do_action(params[:id], params[:space_id], 'remove_from_wishlist')
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

      def do_action(user_id, space_id, method)
        return record_not_found unless Space.find_by(id: params[:space_id]).present?
        relationship = UsersFavoriteContext.new(user_id, space_id).send(method)
        return render_nothing if relationship.present?
        wrong_preconditions
      end

    end
  end
end
