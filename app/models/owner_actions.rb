module OwnerActions

  def spaces_bookings
    Booking.administered_bookings(self)
  end

  def all_bookings
    Booking.all_bookings_for(self)
  end

end
