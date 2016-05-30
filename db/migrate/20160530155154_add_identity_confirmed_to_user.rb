class AddIdentityConfirmedToUser < ActiveRecord::Migration
  def change
    add_column :users, :identity_confirmed, :boolean
  end
end
