class AddPaymentToBookings < ActiveRecord::Migration
  def change
    add_reference :bookings, :payment, polymorphic: true, index: true
  end
end
