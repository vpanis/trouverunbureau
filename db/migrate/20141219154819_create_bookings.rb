class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.belongs_to :user, index: true
      t.belongs_to :space, index: true
      t.string :state
      t.datetime :from
      t.datetime :to
      t.string :b_type
      t.integer :quantity

      t.timestamps
    end
  end
end
