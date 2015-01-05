class User < ActiveRecord::Base
	# Relations
	has_many :venues, as: :owner
	# Organizations that the user have
	has_many :organization_users

	has_many :organizations, through: :organization_users
	# All the venues of the different organizations that the user belongs
	has_many :organization_venues, :through => :organizations, :source => :venues

	has_many :bookings, as: :owner

	has_many :users_favorites

	# Favorited spaces
	has_many :spaces, through: :users_favorites


	# Callbacks
	before_validation :default_rating_values, unless: :created_at

	# Validations
	validates :first_name, :email, :quantity_reviews, :reviews_sum, :rating, 
		presence: true
	
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
		greater_than_or_equal_to: 0,
		less_than_or_equal_to: 5
	}


	private
		def default_rating_values
			self.quantity_reviews ||= 0
			self.reviews_sum ||= 0
			self.rating ||= 0
		end
end
