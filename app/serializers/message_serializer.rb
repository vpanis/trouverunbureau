class MessageSerializer < ActiveModel::Serializer
  attributes :id, :m_type, :text, :represented, :date

  has_one :user, serializer: UserSerializer

  def represented
    if object.represented != object.booking.owner
      return VenueSerializer.new(object.booking.space.venue)
    end
    return nil if object.booking.owner == object.represented
    OrganizationSerializer.new(object.booking.owner)
  end

  def date
    object.created_at.to_s
  end

end
