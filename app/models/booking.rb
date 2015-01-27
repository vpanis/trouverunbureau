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
  before_validation :time_local_to_utc

  # Validations
  validates :owner, :space, :b_type, :quantity, :from, :to, presence: true

  validates :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  class << self

    def bookable?(space, booking_type, from, to, quantity)
      check_availability(space, booking_type, from, to, quantity).empty?
    end

    def check_availability(space, booking_type, from, to, quantity)
      field_errors = []
      utc_from = Time.zone.local_to_utc(from)
      utc_to = Time.zone.local_to_utc(to)
      verify_quantity(field_errors, space, quantity)
      field_errors.push(type: :from_date_bigger_than_to, from: from, to: to) if utc_from > utc_to
      field_errors.push(type: :invalid_venue_hours) unless valid_hours_for_venue?(space.venue,
                                                                                  booking_type,
                                                                                  utc_from, utc_to)
      return field_errors unless field_errors.empty?
      check_max_collition(space, utc_from, utc_to, quantity)
    end

    def block_states
      [states[:pending_payment], states[:paid], states[:already_taken]]
    end

    private

    def check_max_collition(space, from, to, quantity)
      rdc = RangeDateCollider.new(max_collition_permited: space.quantity - quantity,
                                  first_date: from, minute_granularity: 30)
      Booking.where(':from BETWEEN bookings.from AND bookings.to OR
        :to BETWEEN bookings.from AND bookings.to', from: from, to: to)
        .where(space: space).where { state.eq_any my { block_states } }
        .order(from: :asc).each do |booking|
        rdc.add_time_range(booking.from, booking.to, booking.quantity)
        break unless rdc.valid?
      end

      rdc.errors
    end

    def valid_hours_for_venue?(venue, booking_type, from, to)
      case booking_type
      when b_types[:hour]
        venue.opens_hours_from_to?(from, to)
      when b_types[:day]
        venue.opens_days_from_to?(from, to)
      else
        # if the venue opens at least 1 hour, 1 day per week, the user can book for week and month
        !venue.day_hours.empty?
      end
    end

    def verify_quantity(errors, space, quantity)
      errors.push(type: :invalid_quantity, quantity: quantity) if quantity < 1
      errors.push(type: :quantity_exceed_max, quantity: quantity) if space.quantity < quantity
    end
  end

  private

  def initialize_fields
    self.state ||= Booking.states[:pending_authorization]
  end

  def time_local_to_utc
    self.from = Time.zone.local_to_utc(from)
    self.to = Time.zone.local_to_utc(to)
  end

end
