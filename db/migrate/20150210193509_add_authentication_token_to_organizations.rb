class AddAuthenticationTokenToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :authentication_token, :string
    add_index :organizations, :authentication_token
  end
end
