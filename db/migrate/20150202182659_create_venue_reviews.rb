class CreateVenueReviews < ActiveRecord::Migration
  def change
    create_table :venue_reviews do |t|
      t.string :message
      t.integer :stars
      t.boolean :active

      t.timestamps
    end
  end
end
