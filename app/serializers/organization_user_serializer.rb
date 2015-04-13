class OrganizationUserSerializer < ActiveModel::Serializer
  attributes :id, :role

  has_one :user, serializer: UserSerializer
  has_one :organization, serializer: OrganizationSerializer
end
