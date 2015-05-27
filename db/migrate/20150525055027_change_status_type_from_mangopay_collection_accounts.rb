class ChangeStatusTypeFromMangopayCollectionAccounts < ActiveRecord::Migration
  def change
    change_column :mangopay_collection_accounts, :status, 'integer USING status::int'
  end
end
