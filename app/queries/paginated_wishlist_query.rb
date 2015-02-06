class PaginatedWishlistQuery < PaginatedQuery

  def wishlist(pagination_params, user_id)
    @relation = select_favorites_for_user(user_id)
    paginate(pagination_params)
    @relation
  end

  def select_favorites_for_user(user_id)
    ans = UsersFavorite.where { users_favorites.user_id == my { user_id } }. joins { space }
    ans.includes { [space.venue, space.photo] }
  end
end
