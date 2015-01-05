class VenueWorker < ActiveRecord::Base
	# Relations
	belongs_to :user
	belongs_to :venue

	# Constants/Enums
	ROLES = [:owner, :admin]

	# Validations
	validates :user, :venue, presence: true
	validates :role, inclusion: { in: ROLES.map(&:to_s) }
end
