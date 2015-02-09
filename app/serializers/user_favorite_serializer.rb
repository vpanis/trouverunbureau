class UserFavoriteSerializer < ActiveModel::Serializer
  attributes :id, :name, :city, :currency, :hour_price, :day_price, :week_price, :month_price,
             :photos

  def id
    object.space.id
  end

  def name
    object.space.name
  end

  def city
    object.space.venue.town
  end

  def currency
    object.space.venue.currency
  end

  def hour_price
    object.space.hour_price
  end

  def day_price
    object.space.day_price
  end

  def week_price
    object.space.week_price
  end

  def month_price
    object.space.month_price
  end

  def photos
    space_photos = []
    space_photos << object.space.photo.url if object.space.photo
    # TODO: remember that a space can have more than one photos
    space_photos
  end
end
