class WishlistQuery < PaginatedQuery

  def initialize(user_id)
    @user_id = user_id
  end

  def wishlist(pagination_params)
    @relation = select_favorites
    paginate(pagination_params)
    @relation
  end

  def select_favorites
    UsersFavorite.where { users_favorites.user_id == my { @user_id } }. joins { space }
                                .includes { [space.venue, space.photo] }.order { spaces.name.asc }
    # TODO: check the order criteria
  end

  def exists(space_id)
    UsersFavorite.where(user_id: @user_id, space_id: space_id).one?
  end

end
