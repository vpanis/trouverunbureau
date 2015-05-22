class AddNextPayoutAtToMangopayPayments < ActiveRecord::Migration
  def change
    add_column :mangopay_payments, :next_payout_at, :datetime
  end
end
