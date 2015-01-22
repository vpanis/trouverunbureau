class VenueHour < ActiveRecord::Base
  # Relations
  belongs_to :venue

  # weekday is the days_to_week_start fn in Time class (Mon:0, Tues:1, ...)

  before_validation :hours_local_to_utc, unless: :created_at

  # Validations
  validates :venue, :from, :to, :weekday, presence: true

  validates :weekday, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than: 7
  }

  class << self
    def which_day(time)
      (time.wday - 1) % 7
    end

    def days_covered(from, to)
      days = (to.at_end_of_day - from.at_beginning_of_day).round / 1.day
      days = 7 if days > 7
      start_wday = which_day(from)
      if start_wday + (days - 1) > 6
        (start_wday..6).to_a + (0..((days - 1) - (7 - start_wday))).to_a
      else
        (start_wday..(start_wday + days - 1)).to_a
      end
    end
  end

  private

  def hours_local_to_utc
    self.from = Time.zone.local_to_utc(from)
    self.to = Time.zone.local_to_utc(to)
  end
end
