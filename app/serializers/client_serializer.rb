class ClientSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :avatar, :rating, :quantity_reviews

  def type
    object.class.to_s
  end

  def avatar
    return object.logo.url if object.class == Organization
    object.avatar.url
  end

  def name
    return object.first_name if object.class == User
    object.name
  end

end
