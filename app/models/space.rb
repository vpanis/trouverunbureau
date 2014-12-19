class Space < ActiveRecord::Base
	belongs_to :venue

	has_many :bookings

	TYPES = [:conference_room, :meeting_room, :office, :desk]
end
