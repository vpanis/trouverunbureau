class ClientSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :avatar

  def type
    object.class.to_s
  end

  def avatar
    return object.logo.url if object.class == Organization
    object.avatar.url
  end
end
