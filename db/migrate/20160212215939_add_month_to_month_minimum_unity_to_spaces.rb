class AddMonthToMonthMinimumUnityToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :month_to_month_minimum_unity, :integer, default: 1, null: false
    add_column :spaces, :month_to_month_price, :integer
  end
end
