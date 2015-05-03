class AddTransferenceIdAndPayoutIdToMangopayPayments < ActiveRecord::Migration
  def change
    add_column :mangopay_payments, :transference_id, :string
    add_column :mangopay_payments, :payout_id, :string
  end
end
