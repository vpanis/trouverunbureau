class CreateMangopayPayments < ActiveRecord::Migration
  def change
    create_table :mangopay_payments do |t|
      t.string :transaction_status
      t.string :transaction_id
      t.text :error_message
      t.string :card_type
      t.string :card_last_4
      t.string :card_expiration_date

      t.timestamps
    end
  end
end
