class AddCardInfoToBraintreePayments < ActiveRecord::Migration
  def change
    add_column :braintree_payments, :card_type, :string
    add_column :braintree_payments, :card_last_4, :string
    add_column :braintree_payments, :card_expiration_date, :string
  end
end
