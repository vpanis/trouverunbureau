class Booking < ActiveRecord::Base
  attr_accessor :user
  # Relations
  belongs_to :owner, polymorphic: true
  belongs_to :payment, polymorphic: true

  belongs_to :space

  has_many :messages
  has_one :client_review
  has_one :venue_review

  # Constants/Enums
  enum b_type: [:hour, :day, :week, :month, :month_to_month]

  # Beware: tye Messages m_types must contain the Booking states
  enum state: [:pending_authorization, :pending_payment, :paid, :cancelled, :denied, :expired,
               :payment_verification, :refunding, :error_refunding]

  # Callbacks
  after_initialize :initialize_fields
  before_validation :calculate_price, unless: :price?

  before_validation :calculate_fee, if: :price_changed?

  # Validations
  validates :owner, :space, :b_type, :quantity, :from, :to, :price, presence: true

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  validates :price, :fee, :deposit, numericality: { greater_than_or_equal_to: 0 }

  validate :from_smaller_than_to
  validate :minimum_time_reached

  scope :not_deleted_owner, -> { where(owner_delete: false) }
  scope :not_deleted_venue_owner, -> { where(venue_owner_delete: false) }

  acts_as_decimal :price, decimals: 2
  acts_as_decimal :fee, decimals: 2
  acts_as_decimal :deposit, decimals: 2

  class << self
    def administered_bookings(represented)
      joins { space.venue }.where { space.venue.owner == my { represented } }
    end

    def all_bookings_for(owner_client)
      joins { space.venue }.where do
        (owner == my { owner_client }) | (space.venue.owner ==  my { owner_client })
      end.distinct.order('bookings.updated_at DESC')
    end
  end

  def from=(from)
    from = Time.zone.local_to_utc(from) if from.is_a? Time
    super(from)
  end

  def to=(to)
    to = Time.zone.local_to_utc(to) if to.is_a? Time
    super(to)
  end

  def state_if_represented_cancels(represented)
    return Booking.states[:cancelled] if owner == represented
    return Booking.states[:denied] if space.venue.owner == represented
    nil
  end

  private

  def initialize_fields
    self.state ||= Booking.states[:pending_authorization]
    self.deposit ||= 0
    self.confirmation_code ||= SecureRandom.hex(4)
  end

  def calculate_price
    return unless space.respond_to?("#{b_type}_price")
    unit_price = space.send("#{b_type}_price")
    return errors.add(:price_not_found_for_b_type, b_type: b_type) unless unit_price.present?
    self.price ||= unit_price * unit_price_quantity * quantity if quantity.present? && quantity > 0
  end

  def unit_price_quantity
    return 0 unless valid_for_calculate_time_quantity? && space.venue.present?
    case b_type
    when 'day'
      venue_not_open_days = [0, 1, 2, 3, 4, 5, 6] - space.venue.day_hours.pluck(:weekday)
      (VenueHour.weekdays_array(from, to) - venue_not_open_days).length
    when 'month'
      (to.year * 12 + to.month) - (from.year * 12 + from.month) + ((to.day >= from.day) ? 1 : 0)
    when 'month_to_month'
      1
    else
      ((to - from) / 1.send(b_type)).ceil
    end
  end

  # 20% for hourly, dayly, and for the first month of monthly/month-to-month rents
  # 10% for each month or part thereof after the first month of monthly/month-to-month rents
  def calculate_fee
    first_unit_price = (1.0/unit_price_quantity) * price
    self.fee = PayConf.deskspotting_fee * first_unit_price
    if unit_price_quantity > 1
      remainder_fee_factor = if %w(month month_to_month).include? b_type
        PayConf.deskspotting_fee2.to_f
      else
        PayConf.deskspotting_fee.to_f
      end
      remainder_price = price - first_unit_price
      Rails.logger.info remainder_price.class 
      Rails.logger.info remainder_fee_factor.class 
      Rails.logger.info remainder_price 
      Rails.logger.info remainder_fee_factor
      self.fee += remainder_price * remainder_fee_factor
    end
  end

  def minimum_time_reached
    return unless b_type.present? && valid_for_calculate_time_quantity?
    errors.add(:minimum_time, 'you must at least reach the minimum time') if
      space.send("#{b_type}_minimum_unity") > unit_price_quantity
  end

  def from_smaller_than_to
    return if from.blank? || to.blank?
    errors.add(:from_date_bigger_than_to, 'from must be smaller than to') if from > to
  end

  def valid_for_calculate_time_quantity?
    space.present? && !from.blank? && !to.blank? && from <= to
  end
end
