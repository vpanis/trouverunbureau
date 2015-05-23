class CreateMangopayPayouts < ActiveRecord::Migration
  def change
    create_table :mangopay_payouts do |t|
      t.integer :p_types
      t.string :transaction_id
      t.string :transference_id
      t.string :transaction_status
      t.text :error_message
      t.references :mangopay_payment, index: true
      t.integer :notification_date_int
      t.integer :amount
      t.integer :fee
      t.integer :retries

      t.timestamps
    end

    add_index :mangopay_payouts, :transaction_id, unique: true
    add_index :mangopay_payouts, :transference_id, unique: true
  end
end
