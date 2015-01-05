class ReviewUser < ActiveRecord::Base
	# Relations
	belongs_to :user
	belongs_to :from_user, class_name: "User"

	# Callbacks
	before_validation :default_active, unless: :created_at
	after_create :increase_ratings, if: :active
	after_destroy :decrease_ratings, if: :active

	# Validations
	validates :user, :from_user, :stars, presence: true
	validates :stars, numericality: {
		only_integer: true,
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 5
	}

	def deactivate!
		self.active = false
		self.save
		decrease_ratings
	end

	def activate!
		self.active = true
		self.save
		increase_ratings
	end

	private
		# starts active
		def default_active
			self.active ||= true
		end

		def increase_ratings
			user.quantity_reviews = user.quantity_reviews + 1
			user.reviews_sum = user.reviews_sum + stars
			user.rating = user.reviews_sum / (user.quantity_reviews * 1.0)
			user.save
		end

		def decrease_ratings
			user.quantity_reviews = user.quantity_reviews - 1
			user.reviews_sum = user.reviews_sum - stars
			if user.quantity_reviews != 0
				user.rating = user.reviews_sum / (user.quantity_reviews * 1.0)
			else 
				user.rating = 0
			end
			user.save
		end
end
