class AddGuestDataToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :main_guest_email, :string
    add_column :bookings, :main_guest_name, :string
  end
end
