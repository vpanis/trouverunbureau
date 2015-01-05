class OrganizationUser < ActiveRecord::Base
	# Relations
	belongs_to :user
	belongs_to :organization

	# Constants/Enums
	ROLES = [:owner, :admin]

	# Validations
	validates :user, :organization, :role, presence: true
	validates :role, inclusion: { in: ROLES.map(&:to_s) }
end
