class Booking < ActiveRecord::Base
  # Relations
  belongs_to :owner, polymorphic: true

  belongs_to :space

  has_many :messages

  # Constants/Enums
  enum b_type: [:hour, :day, :week, :month]

  enum state: [:pending_authorization, :pending_payment, :paid,
               :canceled, :denied, :already_taken]

  # Callbacks
  after_initialize :initialize_fields
  before_validation :calculate_price
  before_validation :time_local_to_utc

  # Validations
  validates :owner, :space, :b_type, :quantity, :from, :to, :price, presence: true

  validates :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  validates :price, numericality: {
    greater_than_or_equal_to: 0
  }

  private

  def initialize_fields
    self.state ||= Booking.states[:pending_authorization]
  end

  def time_local_to_utc
    self.from = Time.zone.local_to_utc(from)
    self.to = Time.zone.local_to_utc(to)
  end

  def calculate_price
    return self.price ||= nil unless space.respond_to?("#{b_type}_price")
    self.price ||= space.send("#{b_type}_price")
    errors.add(:price_not_found_for_b_type, b_type: b_type) unless price.present?
  end
end
