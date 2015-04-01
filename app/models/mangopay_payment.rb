class MangopayPayment < ActiveRecord::Base
  has_one :booking, as: :payment
  STATUSES = %w(SUCCEEDED FAILED CREATED)

  validates :transaction_status, inclusion: { in: STATUSES }
end
