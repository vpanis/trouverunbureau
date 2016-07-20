class UsersFavorite < ActiveRecord::Base
  # Relations
  belongs_to :user
  belongs_to :space

  # Validations
  validates :user, :space, presence: true
  validates :space, uniqueness: { scope: :user_id }
end
