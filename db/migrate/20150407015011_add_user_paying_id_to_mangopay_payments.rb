class AddUserPayingIdToMangopayPayments < ActiveRecord::Migration
  def change
    add_reference :mangopay_payments, :user_paying, index: true
  end
end
