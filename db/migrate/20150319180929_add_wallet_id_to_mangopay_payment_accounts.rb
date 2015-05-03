class AddWalletIdToMangopayPaymentAccounts < ActiveRecord::Migration
  def change
    add_column :mangopay_payment_accounts, :wallet_id, :string
  end
end
