class AddIdentityConfirmedToUser < ActiveRecord::Migration
  def change
    add_column :users, :indentity_confirmed, :boolean
  end
end
