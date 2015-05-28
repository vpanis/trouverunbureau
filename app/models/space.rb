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

  def at_least_one_price
    return if hour_price.present? ||
      day_price.present? || week_price.present? || month_price.present?
    errors.add(:price, 'Needs at least one price')
  end

  def hour_price
    self[:hour_price] / 100.0 if self[:hour_price].present?
  end

  def hour_price=(hp)
    super(hp)
    return self[:hour_price] = (hp * 100).to_i if hp.is_a? Numeric
  end

  def day_price
    self[:day_price] / 100.0 if self[:day_price].present?
  end

  def day_price=(hp)
    super(hp)
    return self[:day_price] = (hp * 100).to_i if hp.is_a? Numeric
  end

  def week_price
    self[:week_price] / 100.0 if self[:week_price].present?
  end

  def week_price=(hp)
    super(hp)
    return self[:week_price] = (hp * 100).to_i if hp.is_a? Numeric
  end

  def month_price
    self[:month_price] / 100.0 if self[:month_price].present?
  end

  def month_price=(hp)
    super(hp)
    return self[:month_price] = (hp * 100).to_i if hp.is_a? Numeric
  end

  def deposit
    self[:deposit] / 100.0 if self[:deposit].present?
  end

  def deposit=(hp)
    super(hp)
    return self[:deposit] = (hp * 100).to_i if hp.is_a? Numeric
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
