class AddAndRemovePaymentInfoToMangopayPayments < ActiveRecord::Migration
  def change
    remove_column :mangopay_payments, :transference_id, :integer
    remove_column :mangopay_payments, :payout_id, :integer

    add_column :mangopay_payments, :price_amount_in_wallet, :integer
    add_column :mangopay_payments, :deposit_amount_in_wallet, :integer
  end
end
