class Receipt < ActiveRecord::Base
  belongs_to :payment, polymorphic: true
  validates :payment_id, uniqueness: { scope: :payment_type }
  # Uploaders
  mount_uploader :guest_avatar, LogoUploader
end
