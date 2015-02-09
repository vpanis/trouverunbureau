module Api
  module V1
    class WishlistController < ApplicationController
      include ParametersHelper
      respond_to :json

      def wishlist
        return render nothing: true, status: 404 unless User.find_by(id: params[:id]).present?
        result = PaginatedWishlistQuery.new.wishlist(pagination_params, params[:id])
        result.order { spaces.name.desc }
        render json: { count: result.total_entries, current_page: result.current_page,
                       items_per_page: result.per_page,
                       spaces: serialized_reviews(result, UserFavoriteSerializer) },
               status: 200
      end

      def serialized_reviews(result, serializer)
        ActiveModel::ArraySerializer.new(result, each_serializer: serializer)
      end

    end
  end
end
