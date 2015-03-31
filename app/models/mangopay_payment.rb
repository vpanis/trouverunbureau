class MangopayPayment < ActiveRecord::Base
  STATUSES = %w(SUCCEEDED FAILED CREATED)

  validates :transaction_status, inclusion: { in: STATUSES }
end
