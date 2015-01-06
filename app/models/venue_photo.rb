class VenuePhoto < ActiveRecord::Base
  # Relations
  belongs_to :venue
  # Optional
  belongs_to :space

  mount_uploader :photo, PhotoUploader

  # Callbacks
  before_destroy :erase_photo

  # Validations
  validates :venue, :photo, presence: true

  private

  def erase_photo
    self.remove_photo! if photo
  end
end
