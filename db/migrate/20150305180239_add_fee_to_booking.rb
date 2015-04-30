class AddFeeToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :fee, :integer
  end
end
