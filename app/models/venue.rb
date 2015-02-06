class Venue < ActiveRecord::Base
  # Relations
  belongs_to :owner, polymorphic: true

  has_many :spaces, dependent: :destroy

  has_many :day_hours, class_name: 'VenueHour', dependent: :destroy

  has_many :photos, class_name: 'VenuePhoto', dependent: :destroy

  # Uploaders
  mount_uploader :logo, LogoUploader

  # Constants/Enums
  enum v_type: [:coworking_space, :startup_office, :hotel, :corporate_office, :business_center,
                :design_studio, :loft, :apartment, :house, :cafe, :restaurant]

  enum space_unit: [:square_mts, :square_foots]

  AMENITY_TYPES = [:whiteboards, :kitchen, :security, :wifi, :printer_scanner, :chill_area,
                   :photocopier, :conference_rooms, :elevators, :outdoor_space, :team_bookings,
                   :individual_bookings, :shower, :fax, :wheelchair_access, :air_conditioning,
                   :pets_allowed, :mail_service, :gym, :cafe_restaurant, :phone_booth]

  PROFESSIONS = [:technology, :public_relations, :entertainment, :entrepreneur]

  # Callbacks
  after_initialize :initialize_fields
  before_destroy :erase_logo

  # Validations
  validates :town, :street, :postal_code, :country, :email, :latitude, :longitude,
            :name, :description, :currency, :v_type, :vat_tax_rate, :owner,
            presence: true

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
    on: :create
  }

  validates :latitude, numericality: {
    greater_than_or_equal_to: -90,
    less_than_or_equal_to: 90
  }

  validates :longitude, numericality: {
    greater_than_or_equal_to: -180,
    less_than_or_equal_to: 180
  }

  validates :space, :vat_tax_rate, numericality: {
    greater_than_or_equal_to: 0
  }

  validates :floors, :rooms, :desks, :quantity_reviews, :reviews_sum, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :rating, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }

  validate :each_amenity_inclusion
  validate :each_profession_inclusion

  def opens_at_least_one_day_from_to?(from, to)
    weekdays = VenueHour.days_covered(from, to)
    1 <= day_hours.where { weekday.eq_any weekdays }.group(:weekday).count.length
  end

  def opens_days_from_to?(from, to)
    weekdays = VenueHour.days_covered(from, to)
    weekdays.length == day_hours.where { weekday.eq_any weekdays }.group(:weekday).count.length
  end

  def opens_hours_from_to?(from, to)
    from_weekday = VenueHour.which_day(from)
    from = VenueHour.convert_time(from)
    to = VenueHour.convert_time(to)
    1 <= day_hours.where do
      (venue_hours.weekday == my { from_weekday }) &
      (venue_hours.from <= my { from }) &
      (venue_hours.to > my { to })
    end.count
  end

  private

  def initialize_fields
    self.quantity_reviews ||= 0
    self.reviews_sum ||= 0
    self.rating ||= 0
  end

  def erase_logo
    self.remove_logo!
  end

  def each_amenity_inclusion
    invalid_amenities = amenities - AMENITY_TYPES.map(&:to_s)
    invalid_amenities.each do |amenity|
      errors.add(:amenity_list, amenity + ' is not a valid amenity')
    end
  end

  def each_profession_inclusion
    invalid_professions = professions - PROFESSIONS.map(&:to_s)
    invalid_professions.each do |profession|
      errors.add(:profession_list, profession + ' is not a valid amenity')
    end
  end

end
