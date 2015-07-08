class AddErrorCodeToMangopayPayouts < ActiveRecord::Migration
  def change
    add_column :mangopay_payouts, :error_code, :string
  end
end
