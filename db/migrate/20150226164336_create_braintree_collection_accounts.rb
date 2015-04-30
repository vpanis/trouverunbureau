class CreateBraintreeCollectionAccounts < ActiveRecord::Migration
  def change
    create_table :braintree_collection_accounts do |t|
      t.boolean :active, default: false
      t.string :status
      t.text :error_message

      t.timestamps
    end
  end
end
