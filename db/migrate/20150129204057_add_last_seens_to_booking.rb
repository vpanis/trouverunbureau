class AddLastSeensToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :owner_last_seen, :datetime
    add_column :bookings, :venue_last_seen, :datetime
  end
end
