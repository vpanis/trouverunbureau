class AddPaymentNonceTokenToBraintreePayments < ActiveRecord::Migration
  def change
    add_column :braintree_payments, :payment_nonce_token, :text
    add_column :braintree_payments, :payment_nonce_expire, :datetime
  end
end
