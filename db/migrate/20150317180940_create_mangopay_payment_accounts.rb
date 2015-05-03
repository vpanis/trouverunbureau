class CreateMangopayPaymentAccounts < ActiveRecord::Migration
  def change
    create_table :mangopay_payment_accounts do |t|
      t.references :buyer, polymorphic: true, index: true
      t.string :mangopay_user_id

      t.timestamps
    end
  end
end
