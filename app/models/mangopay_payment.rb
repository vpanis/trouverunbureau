class MangopayPayment < ActiveRecord::Base
  has_one :booking, as: :payment
  has_many :mangopay_payouts
  belongs_to :user_paying, class_name: 'User'

  TRANSACTION_STATUSES = %w(EXPECTING_RESPONSE PAYIN_SUCCEEDED PAYIN_FAILED PAYIN_CREATED)

  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }

  def price_amount_in_wallet
    self[:price_amount_in_wallet] / 100.0 if self[:price_amount_in_wallet].present?
  end

  def price_amount_in_wallet=(hp)
    super(hp)
    return self[:price_amount_in_wallet] = (hp * 100).to_i if hp.is_a? Numeric
  end

  def deposit_amount_in_wallet
    self[:deposit_amount_in_wallet] / 100.0 if self[:deposit_amount_in_wallet].present?
  end

  def deposit_amount_in_wallet=(hp)
    super(hp)
    return self[:deposit_amount_in_wallet] = (hp * 100).to_i if hp.is_a? Numeric
  end

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
