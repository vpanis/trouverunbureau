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
	
	# Only one row for an specific day and venue
	validates :venue_id, uniqueness: { scope: :weekday }
end
