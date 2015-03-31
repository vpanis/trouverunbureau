class AddIndexForTransactionIdToMangopayPayments < ActiveRecord::Migration
  def change
    add_index :mangopay_payments, :transaction_id, unique: true
  end
end
