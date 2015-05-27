class AddUserToMangopayPayouts < ActiveRecord::Migration
  def change
    add_reference :mangopay_payouts, :user, index: true
    add_reference :mangopay_payouts, :represented, polymorphic: true, index: true
  end
end
