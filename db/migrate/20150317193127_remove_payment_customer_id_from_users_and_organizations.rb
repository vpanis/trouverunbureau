class RemovePaymentCustomerIdFromUsersAndOrganizations < ActiveRecord::Migration
  def change
    remove_column :users, :payment_customer_id
    remove_column :organizations, :payment_customer_id
  end
end
