class CreateTimeZones < ActiveRecord::Migration
  def change
    create_table :time_zones do |t|
      t.string :zone_identifier
      t.integer :minute_utc_difference

      t.timestamps
    end
    add_index :time_zones, :zone_identifier, unique: true
  end
end
