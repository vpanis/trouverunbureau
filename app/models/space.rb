class Space < ActiveRecord::Base
	# Relations
	belongs_to :venue

	has_many :bookings
	has_one :photo, class_name: "VenuePhoto"

	# Constants/Enums
	TYPES = [:conference_room, :meeting_room, :office, :desk]

	# Validations
	validates :s_type, :name, :capacity, :quantity, :venue, presence: true

	validates :s_type, inclusion: { in: TYPES.map(&:to_s) }

	validates :capacity, :quantity, numericality: { 
		only_integer: true,
		greater_than_or_equal_to: 0 
	}
end
