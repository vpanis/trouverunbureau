class AddDeleteToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :owner_delete, :boolean
    add_column :bookings, :venue_owner_delete, :boolean
  end
end
