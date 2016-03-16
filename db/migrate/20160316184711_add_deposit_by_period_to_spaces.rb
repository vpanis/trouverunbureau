class AddDepositByPeriodToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :hour_deposit, :integer
    add_column :spaces, :day_deposit, :integer
    add_column :spaces, :week_deposit, :integer
    add_column :spaces, :month_deposit, :integer
    add_column :spaces, :month_to_month_deposit, :integer
  end
end
