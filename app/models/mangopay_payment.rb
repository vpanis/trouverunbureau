class MangopayPayment < ActiveRecord::Base
  has_one :booking, as: :payment
  belongs_to :user_paying, class_name: 'User'

  TRANSACTION_STATUSES = %w(EXPECTING_RESPONSE PAYIN_SUCCEEDED PAYIN_FAILED PAYIN_CREATED
                            TRANSFER_SUCCEDED TRANSFER_CREATED TRANSFER_FAILED
                            PAYOUT_SUCCEDED PAYOUT_CREATED PAYOUT_FAILED)

  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }

  def expecting_response?
    transaction_status == 'EXPECTING_RESPONSE'
  end

  # 'payin created' needs a mango validation before 'payin succeded'
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
    transaction_status.in?(%w(FAILED TRANSFER_FAILED PAYOUT_FAILED))
  end
end
