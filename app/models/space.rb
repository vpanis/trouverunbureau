class Space < ActiveRecord::Base
  # Relations
  belongs_to :venue

  has_many :bookings
  has_one :photo, class_name: 'VenuePhoto'

  # Constants/Enums
  enum s_type: [:conference_room, :meeting_room, :office, :desk]

  # Validations
  validates :s_type, :name, :capacity, :quantity, :venue, presence: true

  validates :capacity, :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
end
