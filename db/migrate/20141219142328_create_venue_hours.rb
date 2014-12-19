class CreateVenueHours < ActiveRecord::Migration
  def change
    create_table :venue_hours do |t|
      t.integer :weekday
      t.time :from
      t.time :to
      t.belongs_to :venue, index: true

      t.timestamps
    end
  end
end
