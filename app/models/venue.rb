class Venue < ActiveRecord::Base
  attr_accessor :force_submit
  attr_accessor :force_submit_upd

  # Relations
  belongs_to :owner, polymorphic: true
  belongs_to :country

  has_many :spaces, dependent: :destroy
  has_many :day_hours, class_name: 'VenueHour', dependent: :destroy
  has_many :photos, class_name: 'VenuePhoto', dependent: :destroy

  accepts_nested_attributes_for :day_hours,
                                allow_destroy: true,
                                reject_if: proc { |e| e[:from].blank? || e[:to].blank? }

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

  PROFESSIONS = [:technology, :public_relations, :entertainment, :entrepreneur, :startup, :media, :design, :architect, :advertising, :finance, :consultant, :freelance, :journalist, :fashion, :lawyer, :professor]

  # Callbacks
  after_initialize :initialize_fields
  before_destroy :erase_logo

  # Validations
  validates :town, :street, :postal_code, :country, :email, :latitude, :longitude,
            :currency, :v_type, :owner, presence: true, unless: :force_submit
  validates :description, presence: true, unless: proc { |e| e.force_submit || e.force_submit_upd }
  validates :name, :country, presence: true

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create
  }, unless: :force_submit

  validates :latitude, numericality: {
    greater_than_or_equal_to: -90, less_than_or_equal_to: 90
  }, unless: :force_submit

  validates :longitude, numericality: {
    greater_than_or_equal_to: -180, less_than_or_equal_to: 180
  }, unless: :force_submit

  validates :space, :vat_tax_rate,
            numericality: { greater_than_or_equal_to: 0 }, unless: :force_submit

  validates :floors, :rooms, :desks, :quantity_reviews, :reviews_sum, numericality: {
    only_integer: true, greater_than_or_equal_to: 0
  }, unless: :force_submit

  validates :rating, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 5
  }, unless: :force_submit

  validate :each_amenity_inclusion, unless: :force_submit
  validate :each_profession_inclusion, unless: :force_submit

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
    self.floors ||= 0
    self.rooms ||= 0
    self.desks ||= 0
    self.space ||= 0
    self.vat_tax_rate ||= 0
    self.quantity_reviews ||= 0
    self.reviews_sum ||= 0
    self.rating ||= 0
    self.amenities ||= []
    self.professions ||= []
  end

  def erase_logo
    self.remove_logo!
  end

  def each_amenity_inclusion
    each_inclusion(amenities, :amenity_list, AMENITY_TYPES, ' is not a valid amenity')
  end

  def each_profession_inclusion
    each_inclusion(professions, :profession_list, PROFESSIONS, ' is not a valid profession')
  end

  def each_inclusion(attribute, error_list, enum_list, error_message)
    attribute = [] if attribute.nil?
    invalid_items = attribute - enum_list.map(&:to_s)
    invalid_items.each do |item|
      errors.add(error_list, item + error_message)
    end
  end
end
