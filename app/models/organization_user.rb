class OrganizationUser < ActiveRecord::Base
  # Relations
  belongs_to :user
  belongs_to :organization

  # Constants/Enums
  enum role: [:owner, :admin]

  # Validations
  validates :user, :organization, :role, presence: true
end
