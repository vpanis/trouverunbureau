class AddRedirectUrlToMangopayPayments < ActiveRecord::Migration
  def change
    add_column :mangopay_payments, :redirect_url, :string
  end
end
