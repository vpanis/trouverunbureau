class MessageSerializer < ActiveModel::Serializer
  attributes :id, :m_type, :text, :represented, :date

  has_one :user, serializer: UserSerializer

  def represented
    return VenueSerializer.new(object.booking.space.venue).to_json if
      object.represented != object.booking.owner
    return nil if object.booking.owner == object.user
    OrganizationSerializer.new(object.booking.owner).to_json
  end

  def date
    object.created_at.to_s
  end

end
