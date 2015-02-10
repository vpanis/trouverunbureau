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
    space_photos = []
    space_photos << object.photo.url if object.photo
    # TODO: remember that a space can have more than one photos
    space_photos
  end
end
