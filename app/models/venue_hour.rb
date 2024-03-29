class VenueHour < ActiveRecord::Base
  # Relations
  belongs_to :venue

  # weekday is the days_to_week_start fn in Time class (Mon:0, Tues:1, ...)

  # Validations
  validates :venue, :from, :to, :weekday, presence: true

  validates :weekday, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than: 7
  }

  validates :from, :to, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than: 2400
  }

  validate :possible_hours

  def opened_day?
    from.present? && to.present? && (to > from)
  end

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

    def weekdays_array(from, to)
      days = ((to - from) / 1.day).round
      return [] if days <= 0
      start_wday = which_day(from)
      week = [0, 1, 2, 3, 4, 5, 6]
      weekdays = []
      weekdays += week.slice(start_wday, days)
      days -= weekdays.length
      weekdays + week * (days / 7) + week.slice(0, days % 7)
    end

    def convert_time(time)
      time.hour * 100 + time.min
    end
  end

  private

  def possible_hours
    validate_hour(:from) if from
    validate_hour(:to) if to
  end

  def validate_hour(sym)
    minutes = self[sym] % 100
    return if minutes == 30 || minutes == 0
    errors.add(sym, self[sym].to_s + ' is not a valid hour')
  end
end
