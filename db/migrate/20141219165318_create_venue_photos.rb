class CreateVenuePhotos < ActiveRecord::Migration
  def change
    create_table :venue_photos do |t|
      t.belongs_to :venue, index: true
      t.string :photo

      t.timestamps
    end
  end
end
