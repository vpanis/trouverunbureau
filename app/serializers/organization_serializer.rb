class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo

  def logo
    return nil unless object.logo
    object.logo.url
  end

end
