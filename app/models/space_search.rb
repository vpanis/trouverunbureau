# Class with virtual fields, not persisted in the database
class SpaceSearch
  include ActiveModel::Model

  # Space.s_types (:desk, :office...)
  attr_accessor :space_types
  # Venue.v_types (:startup_office, :studio...)
  attr_accessor :venue_types, :venue_amenities, :venue_professions, :venue_states
  # Venue::PROFESSIONS array ("technology", "public_relations"...)
  attr_accessor :latitude_from, :latitude_to, :longitude_from, :longitude_to
  attr_accessor :capacity_max, :capacity_min, :quantity, :date, :weekday

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
    date = attributes[:date] || attributes['date']
    # wday 0 = sunday, venue_hours.weekday 0 = mon
    unless date.blank?
      date_to_utc = Time.zone.local_to_utc(Time.parse(date))
      attributes[:weekday] ||= VenueHour.which_day(date_to_utc)
    end
    super(attributes)
  end

  def fill_conditions(spaces)
    spaces = space_conditions(spaces)
    venue_conditions(spaces)
  end

  def space_conditions(spaces)
    spaces = capacity_conditions(spaces)
    spaces = spaces.where { quantity >= my { quantity } } unless quantity.blank?
    spaces = spaces.where { s_type.eq_any my { space_types } } unless space_types.blank?
    spaces.where(active: true)
  end

  def capacity_conditions(spaces)
    if capacity_min != capacity_max
      spaces = spaces.where { capacity >= my { capacity_min } } unless capacity_min.blank?
      spaces = spaces.where { capacity <= my { capacity_max } } unless capacity_max.blank?
    else
      spaces = spaces.where { capacity == my { capacity_min } } unless capacity_min.blank?
    end
    spaces
  end

  def venue_conditions(spaces)
    spaces = spaces_with_venues(spaces)
    spaces = latitude_longitude_conditions(spaces)
    spaces = spaces.where { venue.v_type.eq_any my { venue_types } } unless venue_types.blank?
    spaces = spaces.where('venues.status IN (?)', venue_states) if venue_states.present?
    spaces = spaces.where('ARRAY[:amenities] <@ venues.amenities',
                          amenities: venue_amenities) unless venue_amenities.blank?
    spaces = spaces.where('ARRAY[:venue_professions] && venues.professions',
                          venue_professions: venue_professions) unless venue_professions.blank?
    return spaces if weekday.blank?
    # day_hours is the name of the relation in venue, venue_hours the name of the table
    spaces.joins { venue.day_hours } .where { venue_hours.weekday == my { weekday } }
  end

  def spaces_with_venues(spaces)
    spaces.joins(:venue)
          .joins('LEFT OUTER JOIN referral_stats on referral_stats.venue_id = venues.id')
          .order('venues.quantity_reviews DESC,
                 (venues.rating * COALESCE(referral_stats.multiplier, 1))  DESC')
  end

  def latitude_longitude_conditions(spaces)
    spaces = longitude_conditions(spaces) if longitude_from.present? && longitude_to.present?
    spaces = latitude_conditions(spaces) if latitude_from.present? && latitude_to.present?
    spaces
  end

  def latitude_conditions(spaces)
    spaces.where { venue.latitude >= my { latitude_from } }
          .where { venue.latitude <= my { latitude_to } }
  end

  # if i look at russia and alaska, longitude_from is 124 and longitude_to is -10
  # the spaces should be (between 124 and 180) or (between -180 and -10)
  def longitude_conditions(spaces)
    return normal_longitude_conditions(spaces) if longitude_from.to_f <= longitude_to.to_f
    spaces.where do
      (venue.longitude >= my { longitude_from }) | (venue.longitude <= my { longitude_to })
    end
  end

  def normal_longitude_conditions(spaces)
    spaces.where { venue.longitude >= my { longitude_from } }
          .where { venue.longitude <= my { longitude_to } }
  end

  def each_amenity_inclusion
    return unless venue_amenities.present?
    invalid_amenities = venue_amenities - Venue::AMENITY_TYPES.map(&:to_s)
    invalid_amenities.each { |a| errors.add(:venue_amenity, a + ' is not a valid amenity') }
  end

  def each_profession_inclusion
    invalid_professions = venue_professions - Venue::PROFESSIONS.map(&:to_s)
    invalid_professions.each { |p| errors.add(:profession_list, p + ' is not a valid amenity') }
  end
end
