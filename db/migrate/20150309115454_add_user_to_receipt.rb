class AddUserToReceipt < ActiveRecord::Migration
  def change
    add_column :receipts, :guest_first_name, :string
    add_column :receipts, :guest_last_name, :string
    add_column :receipts, :guest_avatar, :string
    add_column :receipts, :guest_location, :string
    add_column :receipts, :guest_email, :string
    add_column :receipts, :guest_phone, :string
  end
end
