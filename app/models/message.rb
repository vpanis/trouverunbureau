class Message < ActiveRecord::Base
  attr_accessor :not_flag_as_seen

  belongs_to :booking
  belongs_to :represented, polymorphic: true
  belongs_to :user

  # Beware: it must contain the Booking states
  enum m_type: [:text, :booking_change, :pending_authorization, :pending_payment, :paid,
                :cancelled, :denied, :expired, :payment_verification, :refunding, :error_refunding,
                :payment_error]

  validates :m_type, :represented, presence: true
  validates :text, presence: true, if: proc { |e| e.m_type == 'text' }
  validates :user, presence: true, unless: proc { |e| e.m_type == 'pending_authorization' }

  scope :by_user, ->(user) { where(user: user) }

  def destination_recipient
    sender_is_guest? ? 'host' : 'guest'
  end

  def sender_is_guest?
    booking.owner == user
  end
end
