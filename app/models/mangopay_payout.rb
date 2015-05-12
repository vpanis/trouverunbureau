class MangopayPayout < ActiveRecord::Base
  belongs_to :mangopay_payment

  TRANSACTION_STATUSES = %w(TRANSFER_SUCCEEDED TRANSFER_CREATED TRANSFER_FAILED
                            TRANSACTION_SUCCEEDED TRANSACTION_CREATED TRANSACTION_FAILED)

  enum p_types: [:refund, :payout_to_user]

  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }

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
end
