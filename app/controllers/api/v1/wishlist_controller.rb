module Api
  module V1
    class WishlistController < ApplicationController
      include ParametersHelper
      respond_to :json
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def wishlist
        return render nothing: true, status: 404 unless User.find_by(id: params[:id]).present?
        result = PaginatedWishlistQuery.new.wishlist(pagination_params, params[:id])
        result.order { spaces.name.desc }
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       spaces: serialized_reviews(result, UserFavoriteSerializer) },
               status: 200
      end

      def add_space_to_wishlist
        user = User.find( params[:id])
        space = Space.find(params[:space_id])
        relationship = UsersFavoriteContext.new(user, space).add_to_wishlist
        return render_nothing if relationship.present?
        wrong_preconditions
      end

      def remove_space_from_wishlist
        user = User.find( params[:id])
        space = Space.find(params[:space_id])
        relationship = UsersFavoriteContext.new(user, space).remove_from_wishlist
        return render_nothing if relationship.present?
        wrong_preconditions
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
