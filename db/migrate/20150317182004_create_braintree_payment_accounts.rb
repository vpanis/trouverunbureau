class CreateBraintreePaymentAccounts < ActiveRecord::Migration
  def change
    create_table :braintree_payment_accounts do |t|
      t.references :buyer, polymorphic: true, index: true
      t.string :braintree_customer_id

      t.timestamps
    end
  end
end
