class AddStatusAndErrorMessageToMangopayPaymentAccounts < ActiveRecord::Migration
  def change
    add_column :mangopay_payment_accounts, :status, :integer
    add_column :mangopay_payment_accounts, :error_message, :text
  end
end
