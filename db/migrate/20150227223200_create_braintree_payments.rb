class CreateBraintreePayments < ActiveRecord::Migration
  def change
    create_table :braintree_payments do |t|
      t.string :transaction_status
      t.string :escrow_status
      t.string :transaction_id
      t.text :error_message

      t.timestamps
    end
  end
end
