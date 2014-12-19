class User < ActiveRecord::Base
	# Needed to get the venues where this user has permissions but it isn't the owner
	has_many :venue_workers
	has_many :venues, through: :venue_workers

	has_many :users_favorites

	# Favorited spaces
	has_many :spaces, through: :users_favorites
end
