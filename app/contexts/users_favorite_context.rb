class UsersFavoriteContext

  def initialize(user_id, space_id)
    @user_id = user_id
    @space_id = space_id
  end

  def wishlisted?
    WishlistQuery.new(@user_id).exists(@space_id)
  end

  def add_to_wishlist
    return false if wishlisted?
    UsersFavorite.create!(user_id: @user_id, space_id: @space_id)
  end

  def remove_from_wishlist
    return false unless wishlisted?
    UsersFavorite.where(user_id: @user_id, space_id: @space_id)
                                        .first.destroy!
  end

end
