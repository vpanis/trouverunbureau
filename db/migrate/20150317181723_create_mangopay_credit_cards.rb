class CreateMangopayCreditCards < ActiveRecord::Migration
  def change
    create_table :mangopay_credit_cards do |t|
      t.string :credit_card_id
      t.string :last_4
      t.string :expiration
      t.string :card_type
      t.belongs_to :mangopay_payment_account, index: true

      t.timestamps
    end
  end
end
