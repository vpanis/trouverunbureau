class Venue < ActiveRecord::Base
  include VenueOpenDaysModule
  attr_accessor :force_submit
  attr_accessor :force_submit_upd

  # Relations
  belongs_to :owner, polymorphic: true
  belongs_to :time_zone

  has_many :spaces, dependent: :destroy
  has_many :bookings, through: :spaces
  has_many :day_hours, class_name: 'VenueHour', dependent: :destroy
  has_many :photos, class_name: 'VenuePhoto', dependent: :destroy
  has_one :referral_stat
  belongs_to :collection_account, polymorphic: true, dependent: :destroy

  accepts_nested_attributes_for :day_hours, allow_destroy: true, reject_if:
                                            proc { |e| e[:from].blank? || e[:to].blank? }

  # Uploaders
  mount_uploader :logo, LogoUploader

  # Constants/Enums
  enum v_type: [:coworking_space, :startup_office, :hotel, :corporate_office, :business_center,
                :design_studio, :loft, :apartment, :house, :cafe, :restaurant]

  enum space_unit: [:square_mts, :square_foots]

  enum status: [:creating, :active, :reported, :closed]

  AMENITY_TYPES = [:whiteboards, :kitchen, :security, :wifi, :printer_scanner, :chill_area,
                   :photocopier, :conference_rooms, :elevators, :outdoor_space, :team_bookings,
                   :shower, :fax, :wheelchair_access, :air_conditioning, :tv,
                   :pets_allowed, :mail_service, :gym, :cafe_restaurant, :phone_booth, :projector,
                   :concierge, :parking, :water_fountain, :reception_service, :cleaning_service]

  # SUPPORTED_CURRENCIES = %w(usd gbp eur cad aud)
  # SUPPORTED_COUNTRIES = %w(US CA AU DE AD AT BE HR DK ES FI FR GR IE IS IT NO SE CH GB PL PT NL
  #                         CY EE LV LT LU MT SK SI)

  SUPPORTED_COUNTRIES = %w(FR DE NL BE LU PT AT IT ES FI)
  SUPPORTED_CURRENCIES = %w(eur)

  PROFESSIONS = [:technology, :public_relations, :entertainment, :entrepreneur, :startup, :media,
                 :design, :architect, :advertising, :finance, :consultant, :freelance, :journalist,
                 :fashion, :lawyer, :professor]

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :town, :street, :postal_code, :email, :latitude, :longitude,
            :currency, :v_type, :owner, presence: true, unless: :force_submit
  validates :currency, inclusion: { in: SUPPORTED_CURRENCIES }, unless: :force_submit
  validates :description, presence: true, unless: proc { |e| e.force_submit || e.force_submit_upd }
  validates :name, :country_code, presence: true
  validates :country_code, inclusion: { in: SUPPORTED_COUNTRIES }
  validate :at_least_one_day_hour, unless: proc { |e| e.force_submit || e.force_submit_upd }

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }, unless: :force_submit

  validates :latitude, numericality: {
    greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, unless: :force_submit

  validates :longitude, numericality: {
    greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, unless: :force_submit

  validates :space, :vat_tax_rate,
            numericality: { greater_than_or_equal_to: 0 }, unless: :force_submit

  validates :floors, :rooms, :desks, :quantity_reviews, :reviews_sum, numericality: {
    only_integer: true, greater_than_or_equal_to: 0 }, unless: :force_submit

  validates :rating, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }, unless: :force_submit

  validate :each_amenity_inclusion, :each_profession_inclusion, unless: :force_submit

  def self.accepted_statuses
    [Venue.statuses[:active], Venue.statuses[:reported]]
  end

  def opens_at_least_one_day_from_to?(from, to)
    venue_opens_at_least_one_day_from_to?(from, to, day_hours)
  end

  def opens_days_from_to?(from, to)
    venue_opens_days_from_to?(from, to, day_hours)
  end

  def opens_hours_from_to?(from, to)
    venue_opens_hours_from_to?(from, to, day_hours)
  end

  def venue_knows_user(user)
    owner == user || bookings.exists?(state: Booking.states[:paid], owner: user)
  end

  protected

  def at_least_one_day_hour
    errors.add(:day_hours, 'you must select at least one') if day_hours.size == 0
  end

  def initialize_fields
    self.floors ||= 0
    self.rooms ||= 0
    self.desks ||= 0
    self.space ||= 0
    self.vat_tax_rate ||= 0
    self.amenities ||= []
    self.professions ||= []
    self.status ||= Venue.statuses[:creating]
    self.currency ||= 'eur'
    initialize_reviews_data
  end

  def initialize_reviews_data
    self.quantity_reviews ||= 0
    self.reviews_sum ||= 0
    self.rating ||= 0
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
    invalid_items.each { |item| errors.add(error_list, item + error_message) }
  end
end
