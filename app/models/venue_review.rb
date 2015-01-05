class VenueReview < ActiveRecord::Base
	# Relations
	belongs_to :venue
	belongs_to :from_user, class_name: "User"

	# Callbacks
	before_validation :default_active, unless: :created_at
	after_create :increase_ratings, if: :active
	after_destroy :decrease_ratings, if: :active

	# Validations
	validates :venue, :from_user, :stars, presence: true
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
			venue.quantity_reviews = venue.quantity_reviews + 1
			venue.reviews_sum = venue.reviews_sum + stars
			venue.rating = venue.reviews_sum / (venue.quantity_reviews * 1.0)
			venue.save
		end

		def decrease_ratings
			venue.quantity_reviews = venue.quantity_reviews - 1
			venue.reviews_sum = venue.reviews_sum - stars
			if venue.quantity_reviews != 0
				venue.rating = venue.reviews_sum / (venue.quantity_reviews * 1.0)
			else 
				venue.rating = 0
			end
			venue.save
		end
end
