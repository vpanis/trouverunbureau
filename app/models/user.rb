class User < ActiveRecord::Base
	# Relations
	# Needed to get the venues where this user has permissions but it isn't the owner
	has_many :venue_workers
	has_many :venues, through: :venue_workers

	has_many :users_favorites

	# Favorited spaces
	has_many :spaces, through: :users_favorites

	has_many :bookings

	# Validations
	validates :first_name, :email, presence: true
	validates :email, format: { 
		with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 
		on: :create 
	}, uniqueness: { 
		case_sensitive: false 
	}

	validates :quantity_reviews, :reviews_sum, numericality: { 
		only_integer: true,
		greater_than_or_equal_to: 0 
	}

	validates :rating, numericality: {
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 5
	}
end
