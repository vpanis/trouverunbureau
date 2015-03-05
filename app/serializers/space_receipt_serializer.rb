class SpaceReceiptSerializer < ActiveModel::Serializer
  attributes :id, :type, :capacity
  has_one :host, serializer: VenueReceiptSerializer

  def type
    object.s_type
  end

  def host
    object.venue
  end
end
