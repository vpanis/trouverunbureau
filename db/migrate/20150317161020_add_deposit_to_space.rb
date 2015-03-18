class AddDepositToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :deposit, :integer
  end
end
