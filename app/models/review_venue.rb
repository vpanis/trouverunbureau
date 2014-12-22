class ReviewVenue < ActiveRecord::Base
	# Relations
	belongs_to :venue
	belongs_to :from_user, class_name: "User"

	# Validations
	validates :venue, :from_user, :stars, presence: true
	validates :stars, numericality: {
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 5
	}	
end
