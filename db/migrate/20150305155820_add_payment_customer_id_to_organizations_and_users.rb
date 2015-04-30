class AddPaymentCustomerIdToOrganizationsAndUsers < ActiveRecord::Migration
  def change
    add_column :users, :payment_customer_id, :string
    add_column :organizations, :payment_customer_id, :string
  end
end
