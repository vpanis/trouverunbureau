class CreateVenueWorkers < ActiveRecord::Migration
  def change
    create_table :venue_workers do |t|
      t.belongs_to :user, index: true
      t.belongs_to :venue, index: true
      t.string :role

      t.timestamps
    end
  end
end
