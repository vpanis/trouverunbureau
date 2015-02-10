class UsersFavoriteContext

  def initialize(user, space)
    @user = user
    @space = space
  end

  def wishlisted?
    UsersFavorite.where(user_id: @user.id, space_id: @space.id).one?
  end

  def add_to_wishlist
    return false if wishlisted?
    UsersFavorite.create!(user_id: @user.id, space_id: @space.id)
  end

  def remove_from_wishlist
    return false unless wishlisted?
    UsersFavorite.where(user_id: @user.id, space_id: @space.id)
                                        .first.destroy!
  end

end
