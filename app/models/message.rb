class Message < ActiveRecord::Base
  belongs_to :booking
  belongs_to :organization
  belongs_to :user

  validates :user, :text, presence: true
end
