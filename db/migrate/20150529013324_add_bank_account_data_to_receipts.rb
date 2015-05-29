class AddBankAccountDataToReceipts < ActiveRecord::Migration
  def change
    add_column :receipts, :bank_type, :string
    add_column :receipts, :account_last_4, :string
  end
end
