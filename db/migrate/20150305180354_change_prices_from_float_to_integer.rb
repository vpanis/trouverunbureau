class ChangePricesFromFloatToInteger < ActiveRecord::Migration
  def up
    change_column :bookings, :price, 'integer USING CAST(price * 100 AS integer)'
    change_column :spaces, :hour_price, 'integer USING CAST(hour_price * 100 AS integer)'
    change_column :spaces, :day_price, 'integer USING CAST(day_price * 100 AS integer)'
    change_column :spaces, :week_price, 'integer USING CAST(week_price * 100 AS integer)'
    change_column :spaces, :month_price, 'integer USING CAST(month_price * 100 AS integer)'
  end

  def down
    change_column :bookings, :price, 'float USING CAST(price * 100 AS float)'
    change_column :spaces, :hour_price, 'float USING CAST(hour_price * 100 AS float)'
    change_column :spaces, :day_price, 'float USING CAST(day_price * 100 AS float)'
    change_column :spaces, :week_price, 'float USING CAST(week_price * 100 AS float)'
    change_column :spaces, :month_price, 'float USING CAST(month_price * 100 AS float)'
  end
end
