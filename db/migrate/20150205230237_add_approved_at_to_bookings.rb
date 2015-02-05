class AddApprovedAtToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :approved_at, :datetime
  end
end
