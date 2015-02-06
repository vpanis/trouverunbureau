class ClientReviewSerializer < ActiveModel::Serializer
  attributes :id, :message, :date

  has_one :venue, serializer: VenueReviewSerializer

  def date
    object.created_at.strftime('%B %Y')
  end

  def venue
    object.booking.space.venue
  end

end
