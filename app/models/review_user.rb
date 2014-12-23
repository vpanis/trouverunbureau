class ReviewUser < ActiveRecord::Base
	# Relations
	belongs_to :user
	belongs_to :from_user, class_name: "User"

	# Callbacks
	before_validation :default_active, unless: :created_at
	after_create :increase_ratings 
	after_destroy :decrease_ratings

	# Validations
	validates :user, :from_user, :stars, presence: true
	validates :stars, numericality: {
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 5
	}

	private
		# starts active
		def default_active
			self.active ||= true
		end

		def increase_ratings
			user.quantity_reviews = user.quantity_reviews + 1
			user.reviews_sum = user.reviews_sum + stars
			user.rating = user.reviews_sum / user.quantity_reviews
			user.save
		end

		def decrease_ratings
			user.quantity_reviews = user.quantity_reviews - 1
			user.reviews_sum = user.reviews_sum - stars
			user.rating = user.reviews_sum / user.quantity_reviews
			user.save
		end
end
