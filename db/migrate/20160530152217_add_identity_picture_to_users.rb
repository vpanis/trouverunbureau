class AddIdentityPictureToUsers < ActiveRecord::Migration
  def change
    add_column :users, :identity_picture, :string
  end
end
