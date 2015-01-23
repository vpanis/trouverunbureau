class ChangeTimeFromVenuesToIntegers < ActiveRecord::Migration
  def change
    change_column :venue_hours, :from, 'integer USING CAST(extract(epoch from venue_hours.from) AS integer)'
    change_column :venue_hours, :to, 'integer USING CAST(extract(epoch from venue_hours.to) AS integer)'
  end
end
