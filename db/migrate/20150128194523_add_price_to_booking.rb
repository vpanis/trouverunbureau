class AddPriceToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :price, :float
  end
end
