class AddMinimumUnityToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :hour_minimum_unity, :integer, null: false, default: 1
    add_column :spaces, :day_minimum_unity, :integer, null: false, default: 1
    add_column :spaces, :week_minimum_unity, :integer, null: false, default: 1
    add_column :spaces, :month_minimum_unity, :integer, null: false, default: 1
  end
end
