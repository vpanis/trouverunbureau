class ChangeFloatToDecimalForLatitudeAndLongitude < ActiveRecord::Migration
  def change
    change_column :venues, :latitude, :decimal
    change_column :venues, :longitude, :decimal
  end
end
