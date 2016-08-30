module Payments
  class MakeAigClaimWorker
    include Sidekiq::Worker

    def perform(booking_id)
      booking = Booking.find(booking_id)
      return false unless booking

      booking.update_attributes!(aig_claim_made: true)
      NotificationsMailer.delay.aig_claim_email(booking.id)
    end
  end
end
