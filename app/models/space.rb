class Space < ActiveRecord::Base
  # Relations
  belongs_to :venue

  has_many :bookings
  has_many :photos, class_name: 'VenuePhoto'

  # Constants/Enums
  enum s_type: [:conference_room, :meeting_room, :private_office, :fixed_desk, :hot_desk,
                :communal_space, :home_office]

  # Validations
  validates :s_type, :name, :capacity, :quantity, :venue, :deposit, presence: true

  validates :capacity, :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :deposit, numericality: { greater_than_or_equal_to: 0 }

  validates :hour_price, :day_price, :week_price, :month_price, numericality: {
    greater_than: 0 }, allow_nil: true

  validates :hour_minimum_unity, :day_minimum_unity, :week_minimum_unity, :month_minimum_unity,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validate :at_least_one_price

  after_initialize :initialize_fields

  acts_as_decimal :hour_price, decimals: 2
  acts_as_decimal :day_price, decimals: 2
  acts_as_decimal :week_price, decimals: 2
  acts_as_decimal :month_price, decimals: 2
  acts_as_decimal :deposit, decimals: 2

  def at_least_one_price
    return if hour_price.present? ||
      day_price.present? || week_price.present? || month_price.present?
    errors.add(:price, 'Needs at least one price')
  end

  private

  def initialize_fields
    self.deposit ||= 0
    self.hour_minimum_unity ||= 1
    self.day_minimum_unity ||= 1
    self.week_minimum_unity ||= 1
    self.month_minimum_unity ||= 1
  end
end
