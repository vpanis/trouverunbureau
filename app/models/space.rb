class Space < ActiveRecord::Base
  # Relations
  belongs_to :venue

  has_many :bookings
  has_many :photos, class_name: 'VenuePhoto'

  # Constants/Enums
  enum s_type: [:conference_room, :meeting_room, :private_office, :fixed_desk, :hot_desk,
                :communal_space, :home_office]

  # Validations
  validates :s_type, :name, :capacity, :quantity, :venue, presence: true

  validates :capacity, :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :hour_deposit, :day_deposit, :week_deposit, :month_deposit, :month_to_month_deposit, numericality: {
    greater_than_or_equal_to: 0 }, allow_nil: true

  validates :hour_price, :day_price, :week_price, :month_price, :month_to_month_price, numericality: {
    greater_than: 0 }, allow_nil: true

  validates :hour_minimum_unity, :day_minimum_unity, :week_minimum_unity,
            numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validates :month_minimum_unity, :month_to_month_minimum_unity,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }

  validate :at_least_one_price

  after_initialize :initialize_fields

  scope :active, -> { where(:active) }

  acts_as_decimal :hour_price, decimals: 2
  acts_as_decimal :day_price, decimals: 2
  acts_as_decimal :week_price, decimals: 2
  acts_as_decimal :month_price, decimals: 2
  acts_as_decimal :month_to_month_price, decimals: 2

  acts_as_decimal :hour_deposit, decimals: 2
  acts_as_decimal :day_deposit, decimals: 2
  acts_as_decimal :week_deposit, decimals: 2
  acts_as_decimal :month_deposit, decimals: 2
  acts_as_decimal :month_to_month_deposit, decimals: 2

  def month_to_month_as_of
    month_to_month_minimum_unity.to_i * 30
  end

  def deposits_attributes
    {
      :hour_deposit           =>  self.hour_deposit.to_i,
      :day_deposit            =>  self.day_deposit.to_i,
      :week_deposit           =>  self.week_deposit.to_i,
      :month_deposit          =>  self.month_deposit.to_i,
      :month_to_month_deposit =>  self.month_to_month_deposit.to_i
    }
    .with_indifferent_access
  end

  def deposit_by_type(booking_type)
    deposit_type = "#{booking_type}_deposit"
    self.deposits_attributes[deposit_type]
  end

  def calculate_deposit(booking_type, quantity)
    self.deposit_by_type(booking_type) * quantity
  end

  private

  def at_least_one_price
    return if hour_price.present? ||
      day_price.present? || week_price.present? || month_price.present? || month_to_month_price.present?
    errors.add(:price, 'Needs at least one price')
  end

  def initialize_fields
    self.hour_minimum_unity ||= 1
    self.day_minimum_unity ||= 1
    self.week_minimum_unity ||= 1
    self.month_minimum_unity ||= 1
    self.month_to_month_minimum_unity ||= 1
  end
end
