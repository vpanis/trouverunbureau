# Class with virtual fields, not persisted in the database
class SpaceSearch
  include ActiveModel::Model

  # Booking.b_types (:hour, :day...)
  attr_accessor :booking_type
  # Space.s_types (:desk, :office...)
  attr_accessor :space_type
  # Venue::AMENITY_TYPES array ("wifi", "cafe_restaurant"...)
  attr_accessor :venue_amenities
  attr_accessor :latitude_from, :latitude_to, :longitude_from, :longitude_to
  attr_accessor :capacity, :date

  def find_spaces 
    Space.find(:all, :conditions => to_conditions, :include => :venues) 
  end

  def to_conditions
    w = Where.new
    w = localization(w)
    w.to_s
  end

  private

  def localization(where)
    where.add "venues.latitude >= ?", latitude_from unless latitude_from.blank?
    where.add "venues.latitude <= ?", latitude_to unless latitude_to.blank?
    where.add "venues.longitude >= ?", longitude_from unless longitude_from.blank?
    where.add "venues.longitude >= ?", longitude_to unless longitude_to.blank?
    where
  end
end
