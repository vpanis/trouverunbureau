module Api
  module V1
    class WishlistController < ApiController
      before_action :authenticate_user!

      def index
        result = WishlistQuery.new(current_user.id).wishlist(pagination_params)
        favorites_ids = result.ids
        render_result(result, serialized_reviews(result, SpaceSerializer, favorites_ids))
      end

      def create
        do_action(params[:id], 'add_to_wishlist')
      end

      def destroy
        do_action(params[:id], 'remove_from_wishlist')
      end

      def serialized_reviews(result, serializer, ids)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer,
                                                 scope: { favorites_ids: ids })
      end

      def do_action(space_id, method)
        return record_not_found unless Space.find_by(id: space_id).present?
        relationship = UsersFavoriteContext.new(current_user.id, space_id).send(method)
        return render_nothing if relationship.present?
        wrong_preconditions
      end

    end
  end
end
