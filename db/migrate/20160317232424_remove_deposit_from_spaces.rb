class RemoveDepositFromSpaces < ActiveRecord::Migration
  def change
    remove_column :spaces, :deposit, :integer
  end
end
