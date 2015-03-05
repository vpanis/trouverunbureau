class AddMerchantAccountIdToBraintreeCollectionAccount < ActiveRecord::Migration
  def change
    add_column :braintree_collection_accounts, :merchant_account_id, :string
  end
end
