class AddIndexesForTransferenceIdAndPayoutIdToMangopayPayments < ActiveRecord::Migration
  def change
    add_index :mangopay_payments, :transference_id, unique: true
    add_index :mangopay_payments, :payout_id, unique: true
  end
end
