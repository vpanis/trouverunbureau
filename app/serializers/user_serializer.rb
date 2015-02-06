class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :avatar

  def name?
    object.first_name + object.last_name
  end

  def avatar
    return nil unless object.respond_to?('avatar') && object.avatar
    object.avatar.url
  end

end
