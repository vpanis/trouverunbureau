class Receipt < ActiveRecord::Base
  belongs_to :booking
  validates :booking_id, uniqueness: true

  # Uploaders
  mount_uploader :guest_avatar, LogoUploader
end
