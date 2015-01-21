# Class with virtual fields, not persisted in the database
class SpaceSearch
  include ActiveModel::Model

  # Space.s_types (:desk, :office...)
  attr_accessor :space_types
  # Venue.v_types (:startup_office, :studio...)
  attr_accessor :venue_types
  # Venue::AMENITY_TYPES array ("wifi", "cafe_restaurant"...)
  attr_accessor :venue_amenities
  attr_accessor :latitude_from, :latitude_to, :longitude_from, :longitude_to
  attr_accessor :capacity, :quantity, :date, :weekday

  # Validations
  validates :latitude_to, :latitude_from, numericality: {
    greater_than_or_equal_to: -90,
    less_than_or_equal_to: 90
  }, allow_nil: true

  validates :longitude_to, :longitude_from, numericality: {
    greater_than_or_equal_to: -180,
    less_than_or_equal_to: 180
  }, allow_nil: true

  validates :capacity, :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }, allow_nil: true

  validates :weekday, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than: 7
  }, allow_nil: true

  validate :each_amenity_inclusion

  def find_spaces
    fill_conditions(Space.all)
  end

  private

  def initialize(attributes = {})
    date = attributes[:date]
    # wday 0 = sunday, venue_hours.weekday 0 = mon
    attributes[:weekday] ||= (Time.parse(date).wday - 1 % 7) unless date.blank?
    super(attributes)
  end

  def fill_conditions(spaces)
    spaces = space_conditions(spaces)
    spaces = venue_conditions(spaces)
    # eager loading
    spaces
  end

  def space_conditions(spaces)
    spaces = spaces.where { capacity >= my { capacity } } unless capacity.blank?
    spaces = spaces.where { quantity >= my { quantity } } unless quantity.blank?
    spaces = spaces.where { s_type.eq_any my { space_types } } unless space_types.blank?
    spaces
  end

  def venue_conditions(spaces)
    spaces = spaces.joins { venue }.order("venues.quantity_reviews DESC, venues.rating DESC")
    spaces = latitude_longitude_conditions(spaces)
    spaces = spaces.where { venue.v_type.eq_any my { venue_types } } unless venue_types.blank?
    spaces = spaces.where('ARRAY[:amenities] <@ amenities',
                          amenities: venue_amenities) unless venue_amenities.blank?
    return spaces if weekday.blank?
    # day_hours is the name of the relation in venue, venue_hours the name of the table
    spaces.joins { venue.day_hours } .where { venue_hours.weekday == my { weekday } }
  end

  def latitude_longitude_conditions(spaces)
    spaces = spaces.where { venue.latitude >= my { latitude_from } } unless latitude_from.blank?
    spaces = spaces.where { venue.latitude <= my { latitude_to } } unless latitude_to.blank?
    spaces = spaces.where { venue.longitude >= my { longitude_from } } unless longitude_from.blank?
    spaces = spaces.where { venue.longitude <= my { longitude_to } } unless longitude_to.blank?
    spaces
  end

  def each_amenity_inclusion
    return unless venue_amenities.present?

    invalid_amenities = venue_amenities - Venue::AMENITY_TYPES.map(&:to_s)
    invalid_amenities.each do |amenity|
      errors.add(:venue_amenity, amenity + ' is not a valid amenity')
    end
  end
end
