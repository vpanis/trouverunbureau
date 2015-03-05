class Receipt < ActiveRecord::Base
  belongs_to :booking
  validates :booking_id, uniqueness: true
end
