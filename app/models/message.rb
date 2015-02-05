class Message < ActiveRecord::Base
  belongs_to :booking
  belongs_to :represented, polymorphic: true
  belongs_to :user

  enum m_type: [:text, :pending_authorization, :pending_payment, :paid,
                :canceled, :denied, :already_taken, :booking_change]

  validates :m_type, :represented, presence: true
  validates :text, presence: true, if: proc { |e| e.m_type == 'text' }
  validates :user, presence: true, unless: proc { |e| e.m_type == 'pending_authorization' }

  after_create :touch_booking_last_seen

  private

  def touch_booking_last_seen
    BookingManager.change_last_seen(booking, represented, created_at)
  end

end
