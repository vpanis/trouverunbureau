class Venue < ActiveRecord::Base
  # Relations
  belongs_to :owner, polymorphic: true

  has_many :spaces, dependent: :destroy

  has_many :day_hours, class_name: 'VenueHour', dependent: :destroy

  has_many :photos, class_name: 'VenuePhoto', dependent: :destroy

  # Uploaders
  mount_uploader :logo, LogoUploader

  # Constants/Enums
  enum v_type: [:startup_office, :studio, :corporate_office, :business_center, :hotel]

  enum space_unit: [:square_mts, :square_foots]

  AMENITY_TYPES = [:wifi, :cafe_restaurant, :catering_available,
                   :coffee_tea_filtered_water, :lockers, :mail_service, :meeting_rooms,
                   :pets_allowed, :phone_booth_room, :shared_kitchen,
                   :wheelchair_accessible]

  # Callbacks
  after_initialize :initialize_fields
  before_destroy :erase_logo

  # Validations
  validates :town, :street, :postal_code, :email, :latitude, :longitude,
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
    end if invalid_amenities
  end
end
