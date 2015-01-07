class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :town
      t.string :street
      t.string :postal_code
      t.string :phone
      t.string :email
      t.string :website
      t.float :latitude
      t.float :longitude
      t.string :name
      t.text :description
      t.string :currency
      t.string :logo
      t.string :v_type
      t.float :space
      t.string :space_unit
      t.integer :floors
      t.integer :rooms
      t.integer :desks
      t.float :vat_tax_rate
      t.text :amenities, array: true, default: []
      t.integer :owner_id

      t.timestamps
    end
  end
end
