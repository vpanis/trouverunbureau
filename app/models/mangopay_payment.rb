class MangopayPayment < ActiveRecord::Base
  has_one :booking, as: :payment
  belongs_to :user_paying, class_name: 'User'

  TRANSACTION_STATUSES = %w(EXPECTING_RESPONSE SUCCEEDED FAILED CREATED)

  validates :transaction_status, inclusion: { in: TRANSACTION_STATUSES }

  def expecting_response?
    transaction_status == 'EXPECTING_RESPONSE'
  end

  def failed?
    transaction_status == 'FAILED'
  end
end
