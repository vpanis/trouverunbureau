class UserReviewSerializer < ActiveModel::Serializer
  attributes :name, :avatar

  def name?
    object.firreturn nil if scope.blank?
    AttendeeContext.new(scope, object).attending?
  end


end
