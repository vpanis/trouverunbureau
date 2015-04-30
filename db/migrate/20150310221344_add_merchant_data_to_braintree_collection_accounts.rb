class AddMerchantDataToBraintreeCollectionAccounts < ActiveRecord::Migration
  def change
    add_column :braintree_collection_accounts, :first_name, :string
    add_column :braintree_collection_accounts, :last_name, :string
    add_column :braintree_collection_accounts, :email, :string
    add_column :braintree_collection_accounts, :phone, :string
    add_column :braintree_collection_accounts, :date_of_birth, :date
    add_column :braintree_collection_accounts, :ssn_last_4, :string
    add_column :braintree_collection_accounts, :individual_street_address, :string
    add_column :braintree_collection_accounts, :individual_locality, :string
    add_column :braintree_collection_accounts, :individual_region, :string
    add_column :braintree_collection_accounts, :individual_postal_code, :string
    add_column :braintree_collection_accounts, :legal_name, :string
    add_column :braintree_collection_accounts, :dba_name, :string
    add_column :braintree_collection_accounts, :tax_id, :string
    add_column :braintree_collection_accounts, :business_street_address, :string
    add_column :braintree_collection_accounts, :business_locality, :string
    add_column :braintree_collection_accounts, :business_region, :string
    add_column :braintree_collection_accounts, :business_postal_code, :string
    add_column :braintree_collection_accounts, :descriptor, :string
    add_column :braintree_collection_accounts, :account_number_last_4, :string
    add_column :braintree_collection_accounts, :routing_number, :string
    add_column :braintree_collection_accounts, :braintree_persisted, :boolean
    add_column :braintree_collection_accounts, :expecting_braintree_response, :boolean
  end
end
