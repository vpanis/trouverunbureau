class AddHoldDepositToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :hold_deposit, :boolean, default: false
  end
end
