class ClientReviewSerializer < ActiveModel::Serializer
  attributes :id, :message, :date

  has_one :venue, serializer: VenueSerializer

  def date
    I18n.l(object.created_at, format: '%B %Y')
  end

  def venue
    object.booking.space.venue
  end

end
