class VenueHour < ActiveRecord::Base
  belongs_to :venue

  # weekday is the days_to_week_start fn in Time class (Mon:0, Tues:1, ...) 
end
