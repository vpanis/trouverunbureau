class AddPaymentTokenToUsersAndOrganizations < ActiveRecord::Migration
  def change
    add_column :users, :payment_token, :text
    add_column :organizations, :payment_token, :text
  end
end
