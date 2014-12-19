class Space < ActiveRecord::Base
	belongs_to :venue

	has_many :bookings
	belongs_to :photo, class_name: "VenuePhoto"

	TYPES = [:conference_room, :meeting_room, :office, :desk]
end
