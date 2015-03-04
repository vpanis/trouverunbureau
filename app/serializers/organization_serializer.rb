class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo

  def logo
    object.logo.url
  end

end
