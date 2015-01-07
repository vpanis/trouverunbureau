class Booking < ActiveRecord::Base
  # Relations
  belongs_to :owner, polymorphic: true

  belongs_to :space

  # Constants/Enums
  enum b_type: [:hour, :day, :week, :month]

  enum state: [:pending_authorization, :pending_payment, :paid,
               :canceled, :denied, :already_taken]

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :owner, :space, :b_type, :quantity, :from, presence: true

  validates :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  private

  def initialize_fields
    self.state ||= Booking.states[:pending_authorization]
  end

end
