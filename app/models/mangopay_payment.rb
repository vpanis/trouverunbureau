class MangopayPayment < ActiveRecord::Base
  has_one :booking, as: :payment
  has_one :receipt, as: :payment
  has_many :mangopay_payouts
  belongs_to :user_paying, class_name: 'User'

  TRANSACTION_STATUSES = %w(EXPECTING_RESPONSE PAYIN_SUCCEEDED PAYIN_FAILED PAYIN_CREATED)

  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }
  validates :price_amount_in_wallet, :deposit_amount_in_wallet,
            presence: true, if: :payin_succeeded?

  acts_as_decimal :price_amount_in_wallet, decimals: 2
  acts_as_decimal :deposit_amount_in_wallet, decimals: 2

  def expecting_response?
    transaction_status == 'EXPECTING_RESPONSE'
  end

  def payin_succeeded?
    transaction_status == 'PAYIN_SUCCEEDED'
  end

  # 'payin created' needs a mango validation before 'payin succeeded'
  def payin_created?
    transaction_status == 'PAYIN_CREATED'
  end

  def failed?
    transaction_status == 'PAYIN_FAILED'
  end
end
