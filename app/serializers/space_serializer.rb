class SpaceSerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :country, :currency, :hour_price, :day_price, :week_price, :month_price, :month_to_month_price,
             :hour_deposit, :day_deposit, :week_deposit, :month_deposit, :month_to_month_deposit,
             :favorite, :latitude, :longitude, :photos, :capacity, :venue_id, :venue_name,
             :logo, :currency_symbol, :space_type, :guaranteed_months

  def guaranteed_months
    object.month_to_month_minimum_unity
  end

  def space_type
    I18n.t("spaces.types.#{object.s_type}")
  end

  def city
    object.venue.town
  end

  def country
    Country.new(object.venue.country_code).try(:name)
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
