class VenueReviewSerializer < ActiveModel::Serializer
  attributes :name, :logo

  def name?
    object.first_name + object.last_name
  end

  def logo
    return nil unless object.logo.url
    object.logo.url
  end

end
