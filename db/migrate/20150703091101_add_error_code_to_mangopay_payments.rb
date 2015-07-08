class AddErrorCodeToMangopayPayments < ActiveRecord::Migration
  def change
    add_column :mangopay_payments, :error_code, :string
  end
end
