module Api
  module V1
    class WishlistController < ApiController

      def wishlist
        return record_not_found unless User.find_by(id: params[:id]).present?
        result = WishlistQuery.new(params[:id]).wishlist(pagination_params)
        favorites_ids = result.ids
        render_result(result, serialized_reviews(result, SpaceSerializer, favorites_ids))
      end

      def add_space_to_wishlist
        do_action(params[:id], params[:space_id], 'add_to_wishlist')
      end

      def remove_space_from_wishlist
        do_action(params[:id], params[:space_id], 'remove_from_wishlist')
      end

      def serialized_reviews(result, serializer, ids)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer,
                                                 scope: { favorites_ids: ids })
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
