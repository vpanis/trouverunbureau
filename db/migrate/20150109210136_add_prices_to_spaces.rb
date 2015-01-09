class AddPricesToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :hour_price, :float
    add_column :spaces, :day_price, :float
    add_column :spaces, :week_price, :float
    add_column :spaces, :month_price, :float
  end
end
