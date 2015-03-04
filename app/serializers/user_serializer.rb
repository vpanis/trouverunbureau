class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :avatar

  def avatar
    return nil unless object.respond_to?('avatar') && object.avatar
    object.avatar.url
  end

end
