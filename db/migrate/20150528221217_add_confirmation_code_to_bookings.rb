class AddConfirmationCodeToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :confirmation_code, :string
    Booking.all.each do |b|
      b.update_attributes(confirmation_code: SecureRandom.hex(4))
    end
  end
end
