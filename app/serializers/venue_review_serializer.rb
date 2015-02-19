class VenueReviewSerializer < ActiveModel::Serializer
  attributes :id, :message, :date

  has_one :owner, serializer: ClientSerializer

  def date
    object.created_at.strftime('%B %Y')
  end

  def owner
    object.booking.owner
  end

end
