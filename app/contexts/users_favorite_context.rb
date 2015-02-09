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
    addition = UsersFavorite.create!(user_id: @user.id, space_id: @space.id)
    # FeedItemContext.new.subscription(@user, @space)
    addition
  end

  def remove_from_wishlist
    return false unless wishlisted?
    remotion = UsersFavorite.where(user_id: @user.id, space_id: @space.id)
                                        .first.destroy!
    remotion
  end

end
