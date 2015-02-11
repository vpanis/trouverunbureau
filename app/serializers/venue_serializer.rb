class VenueSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo

  def name?
    object.first_name + object.last_name
  end

  def logo
    return nil unless object.logo
    object.logo.url
  end

end
