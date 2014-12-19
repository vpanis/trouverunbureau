class Space < ActiveRecord::Base
	belongs_to :venue

	TYPES = [:conference_room, :meeting_room, :office, :desk]
end
