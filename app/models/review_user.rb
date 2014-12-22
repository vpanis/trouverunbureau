class ReviewUser < ActiveRecord::Base
	# Relations
	belongs_to :user
	belongs_to :from_user, class_name: "User"

	# Validations
	validates :user, :from_user, :stars, presence: true
	validates :stars, numericality: {
		greater_than_or_equal_to: 1,
		less_than_or_equal_to: 5
	}
end
