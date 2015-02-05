class ScheduledJobs
  class << self

    def set_expired_bookings
      Booking.where("state = :pending_payment AND approved_at <= :t",
                    t: Time.new.advance(days: -1), pending_payment: Booking.states[:pending_payment])
        .update_all("state = #{Booking.states[:expired]}")
    end

  end
end
