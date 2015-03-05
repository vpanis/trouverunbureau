class Message < ActiveRecord::Base
  belongs_to :booking
  belongs_to :represented, polymorphic: true
  belongs_to :user

  # Beware: it must contain the Booking states
  enum m_type: [:text, :booking_change, :pending_authorization, :pending_payment, :paid,
                :cancelled, :denied, :expired, :payment_verification, :refunding]

  validates :m_type, :represented, presence: true
  validates :text, presence: true, if: proc { |e| e.m_type == 'text' }
  validates :user, presence: true, unless: proc { |e| e.m_type == 'pending_authorization' }

  after_create :touch_booking_last_seen

  private

  def touch_booking_last_seen
    BookingManager.change_last_seen(booking, represented, created_at)
  end

end
