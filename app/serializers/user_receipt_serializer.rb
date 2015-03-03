class UserReceiptSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :avatar, :email, :phone

  def avatar
    return nil unless object.respond_to?('avatar') && object.avatar
    object.avatar.url
  end

end
