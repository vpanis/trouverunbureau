class WishlistQuery
  def initialize(user_id)
    @user_id = user_id
  end

  def wishlist(pagination_params)
    select_favorites.paginate(pagination_params)
  end

  def select_favorites
    spaces_id = UsersFavorite.where { users_favorites.user_id == my { @user_id } }.pluck(:space_id)
    Space.where { id.in spaces_id }. includes { [venue, photos] }.order('spaces.name asc')
    # TODO: check the order criteria
  end

  def exists(space_id)
    UsersFavorite.where(user_id: @user_id, space_id: space_id).one?
  end

end
