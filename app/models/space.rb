class Space < ActiveRecord::Base
  # Relations
  belongs_to :venue

  has_many :bookings
  has_many :photos, class_name: 'VenuePhoto'

  # Constants/Enums
  enum s_type: [:conference_room, :meeting_room, :office, :desk]

  # Validations
  validates :s_type, :name, :capacity, :quantity, :venue, :deposit, presence: true

  validates :capacity, :quantity, :deposit, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :hour_price, :day_price, :week_price, :month_price, numericality: {
    greater_than: 0
  }, allow_nil: true

  validate :at_least_one_price

  after_initialize :initialize_fields

  def at_least_one_price
    return if hour_price.present? ||
      day_price.present? || week_price.present? || month_price.present?
    errors.add(:price, 'Needs at least one price')
  end

  private

  def initialize_fields
    self.deposit ||= 0
  end

end
