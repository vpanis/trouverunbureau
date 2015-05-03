class MangopayPayment < ActiveRecord::Base
  has_one :booking, as: :payment
  belongs_to :user_paying, class_name: 'User'

  TRANSACTION_STATUSES = %w(EXPECTING_RESPONSE PAYIN_SUCCEEDED PAYIN_FAILED PAYIN_CREATED
                            TRANSFER_SUCCEEDED TRANSFER_CREATED TRANSFER_FAILED
                            PAYOUT_SUCCEEDED PAYOUT_CREATED PAYOUT_FAILED
                            REFUND_SUCCEEDED REFUND_CREATED REFUND_FAILED)

  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }

  def expecting_response?
    transaction_status == 'EXPECTING_RESPONSE'
  end

  def payin_succeeded?
    transaction_status == 'PAYIN_SUCCEEDED'
  end

  def transfer_succeeded?
    transaction_status == 'PAYIN_SUCCEEDED'
  end

  def payout_succeeded?
    transaction_status == 'PAYIN_SUCCEEDED'
  end

  # 'payin created' needs a mango validation before 'payin succeeded'
  def payin_created?
    transaction_status == 'PAYIN_CREATED'
  end

  def transfer_created?
    transaction_status == 'TRANSFER_CREATED'
  end

  def payout_created?
    transaction_status == 'PAYOUT_CREATED'
  end

  def failed?
    transaction_status.in?(%w(PAYIN_FAILED TRANSFER_FAILED PAYOUT_FAILED))
  end
end
