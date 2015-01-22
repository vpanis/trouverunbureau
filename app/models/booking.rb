class Booking < ActiveRecord::Base
  # Relations
  belongs_to :owner, polymorphic: true

  belongs_to :space

  # Constants/Enums
  enum b_type: [:hour, :day, :week, :month]

  enum state: [:pending_authorization, :pending_payment, :paid,
               :canceled, :denied, :already_taken]

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :owner, :space, :b_type, :quantity, :from, :to, presence: true

  validates :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  class << self

    def bookable?(space, booking_type, from, to, quantity)
      return false if space.quantity < quantity || quantity < 1 || from > to
      return false unless valid_hours_for_venue?(space.venue, booking_type, from, to)
      Booking.where('bookings.from BETWEEN :from AND :to OR bookings.to BETWEEN :from AND :to',
                    from: from, to: to).where(space: space).find_each do |booking|
        # range logic
      end
    end

    private

    def valid_hours_for_venue?(venue, booking_type, from, to)
      utc_from = Time.zone.local_to_utc(from)
      utc_to = Time.zone.local_to_utc(to)
      case booking_type
      when :hour
        venue.opens_hours_from_to?(utc_from, utc_to)
      when :day
        venue.opens_days_from_to?(utc_from, utc_to)
      else
        # if the venue opens at least 1 hour, 1 day per week, the user can book for week and month
        !venue.day_hours.empty?
      end
    end

  end

  private

  def initialize_fields
    self.state ||= Booking.states[:pending_authorization]
  end

end
