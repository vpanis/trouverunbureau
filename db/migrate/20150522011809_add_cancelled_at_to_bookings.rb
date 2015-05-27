class AddCancelledAtToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :cancelled_at, :datetime
  end
end
