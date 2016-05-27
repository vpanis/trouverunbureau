class VenueReviewSerializer < ActiveModel::Serializer
  attributes :id, :message, :date, :stars

  has_one :owner, serializer: ClientSerializer

  def date
    I18n.l(object.created_at, format: '%B %Y')
  end

  def owner
    object.booking.owner
  end

end
