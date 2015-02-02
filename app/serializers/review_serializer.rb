class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :message

  has_one :user, serializer: UserReviewSerializer

  def attending?
    return nil if scope.blank?
    AttendeeContext.new(scope, object).attending?
  end

  def cover
    object.cover.url
  end

end
