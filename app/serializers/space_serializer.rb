class SpaceSerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :currency, :hour_price, :day_price, :week_price, :month_price,
             :favorite, :latitude, :longitude, :photos, :capacity, :venue_id, :venue_name,
             :deposit, :logo, :currency_symbol

  def city
    object.venue.town
  end

  def currency
    object.venue.currency
  end

  def currency_symbol
    I18n.t("currency.#{object.venue.currency.downcase}.symbol")
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

  def venue_name
    object.venue.name
  end

  def logo
    return object.venue.logo.url if object.venue.logo.present?
    nil
  end

  def favorite
    return false unless scope.present? && scope.include?(:favorites_ids)
    object.id.in?(scope[:favorites_ids])
  end

  def photos
    object.photos.map { |p| p.photo.url }
  end
end
