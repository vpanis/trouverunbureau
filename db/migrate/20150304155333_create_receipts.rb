class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|
      t.references :booking, index: true

      t.timestamps
    end
  end
end
