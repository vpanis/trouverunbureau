class RenameMinuteUtcDifferenceFromTimeZones < ActiveRecord::Migration
  def change
    rename_column :time_zones, :minute_utc_difference, :seconds_utc_difference
  end
end
