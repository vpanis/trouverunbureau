class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :message, :date

  has_one :owner, serializer: UserReviewSerializer

  def date
    object.created_at.strftime('%d/%m/%Y')
  end

  def owner
    object.booking.owner
  end

end
