class SpaceSerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :currency, :hour_price, :day_price, :week_price, :month_price,
             :photos

  def city
    object.venue.town
  end

  def currency
    object.venue.currency
  end

  def photos
    object.photos.map { |p| p.photo.url }
  end
end
