class UserReviewSerializer < ActiveModel::Serializer
  attributes :name, :avatar

  def name?
    object.first_name + object.last_name
  end

  def avatar
    return nil unless object.avatar.url
    object.avatar.url
  end

end
