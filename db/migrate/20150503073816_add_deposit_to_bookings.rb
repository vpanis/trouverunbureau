class AddDepositToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :deposit, :integer
  end
end
