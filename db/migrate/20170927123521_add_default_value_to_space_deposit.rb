class AddDefaultValueToSpaceDeposit < ActiveRecord::Migration
  def change
    change_column :spaces, :hour_deposit, :integer, null: false, default: 0
    change_column :spaces, :day_deposit, :integer, null: false, default: 0
    change_column :spaces, :week_deposit, :integer, null: false, default: 0
    change_column :spaces, :month_deposit, :integer, null: false, default: 0
    change_column :spaces, :month_to_month_deposit, :integer, null: false, default: 0
  end
end
