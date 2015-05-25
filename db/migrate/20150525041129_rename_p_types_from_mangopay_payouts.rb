class RenamePTypesFromMangopayPayouts < ActiveRecord::Migration
  def change
    rename_column :mangopay_payouts, :p_types, :p_type
  end
end
