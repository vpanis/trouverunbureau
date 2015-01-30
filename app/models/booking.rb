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
  after_create :creation_message

  # Validations
  validates :owner, :space, :b_type, :quantity, :from, :to, :price, presence: true

  validates :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  validates :price, numericality: {
    greater_than_or_equal_to: 0
  }

  class << self
    def administered_bookings(represented)
      Booking.joins { space.venue }.where { space.venue.owner == my { represented } }
    end

    def bookings_with_news(represented)
      Booking.joins { space.venue }.joins { messages }
        .where do
          ((owner == my { represented }) & (messages.created_at > bookings.owner_last_seen)) ||
          ((space.venue.owner ==  my { represented }) &
            (messages.created_at > bookings.venue_last_seen))
        end.distinct
    end
  end

  def change_last_seen(represented, last_seen)
    self.owner_last_seen = last_seen if owner == represented
    self.venue_last_seen = last_seen if space.venue.owner == represented
    save
  end

  private

  def creation_message
    messages.create(represented: owner, m_type: Message.m_types[:pending_authorization])
  end

  def initialize_fields
    self.state ||= Booking.states[:pending_authorization]
  end

  def time_local_to_utc
    self.from = Time.zone.local_to_utc(from)
    self.to = Time.zone.local_to_utc(to)
  end

  def calculate_price
    return unless space.respond_to?("#{b_type}_price")
    unit_price = space.send("#{b_type}_price")
    return errors.add(:price_not_found_for_b_type, b_type: b_type) unless unit_price.present?
    self.price ||= unit_price * unit_price_quantity * quantity if quantity.present? && quantity > 0
  end

  def unit_price_quantity
    return 0 unless space.present? && space.venue.present? && from <= to
    if b_type == 'day'
      venue_not_open_days = [0, 1, 2, 3, 4, 5, 6] - space.venue.day_hours.pluck(:weekday)
      (VenueHour.weekdays_array(from, to) - venue_not_open_days).length
    else
      ((to - from) / 1.send(b_type)).round
    end
  end
end
