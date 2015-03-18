class SpaceSerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :currency, :hour_price, :day_price, :week_price, :month_price,
             :favorite, :latitude, :longitude, :photos, :capacity, :venue_id

  def city
    object.venue.town
  end

  def currency
    object.venue.currency
  end

  def latitude
    object.venue.latitude
  end

  def longitude
    object.venue.longitude
  end

  def venue_id
    object.venue.id
  end

  def favorite
    return false unless scope.present? && scope.include?(:favorites_ids)
    object.id.in?(scope[:favorites_ids])
  end

  def photos
    object.photos.map { |p| p.photo.url }
  end
end
