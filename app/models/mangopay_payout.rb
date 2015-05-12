class MangopayPayout < ActiveRecord::Base
  # Relations
  belongs_to :mangopay_payment

  # Constants/Enums
  TRANSACTION_STATUSES = %w(EXPECTING_RESPONSE TRANSFER_SUCCEEDED TRANSFER_CREATED TRANSFER_FAILED
                            TRANSACTION_SUCCEEDED TRANSACTION_CREATED TRANSACTION_FAILED)

  enum p_types: [:refund, :payout_to_user]

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }
  validates :amount, :fee, presence: true

  def amount
    self[:amount] / 100.0 if self[:amount].present?
  end

  def amount=(hp)
    super(hp)
    return self[:amount] = (hp * 100).to_i if hp.is_a? Numeric
  end

  def fee
    self[:fee] / 100.0 if self[:fee].present?
  end

  def fee=(hp)
    super(hp)
    return self[:fee] = (hp * 100).to_i if hp.is_a? Numeric
  end

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
    self.state ||= 'EXPECTING_RESPONSE'
  end
end
