class MangopayPayout < ActiveRecord::Base
  # Relations
  belongs_to :mangopay_payment
  belongs_to :user
  belongs_to :represented, polymorphic: true
  has_one :receipt, as: :payment

  # Constants/Enums
  TRANSACTION_STATUSES = %w(EXPECTING_RESPONSE TRANSFER_SUCCEEDED TRANSFER_CREATED TRANSFER_FAILED
                            TRANSACTION_SUCCEEDED TRANSACTION_CREATED TRANSACTION_FAILED)

  enum p_type: [:refund, :payout_to_user]

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }
  validates :amount, :fee, :aig_fee, presence: true

  acts_as_decimal :amount, decimals: 2
  acts_as_decimal :fee, decimals: 2
  acts_as_decimal :aig_fee, decimals: 2

  def transfer_succeeded?
    transaction_status == 'TRANSFER_SUCCEEDED'
  end

  # Transaction: payout or refund
  def transaction_succeeded?
    transaction_status == 'TRANSACTION_SUCCEEDED'
  end

  def transfer_created?
    transaction_status == 'TRANSFER_CREATED'
  end

  # Transaction: payout or refund
  def transaction_created?
    transaction_status == 'TRANSACTION_CREATED'
  end

  def failed?
    transaction_status == 'TRANSFER_FAILED' || transaction_status == 'TRANSACTION_FAILED'
  end

  private

  def initialize_fields
    self.transaction_status ||= 'EXPECTING_RESPONSE'
    self.aig_fee ||= 0
  end
end
