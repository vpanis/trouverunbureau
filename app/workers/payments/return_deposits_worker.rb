module Payments
  class ReturnDepositsWorker
    include Sidekiq::Worker

    def perform
      bookings = bookings_to_return_deposit
      bookings.each do |booking|
        payout = booking.payment.mangopay_payouts.create(
          amount: booking.payment.deposit_amount_in_wallet,
          fee: 0, p_type: MangopayPayout.p_types[:refund], represented: booking.space.venue.owner,
          user: represented_user(booking.space.venue.owner))
        booking.payment.update_attributes(
          deposit_amount_in_wallet: booking.payment.deposit_amount_in_wallet - payout.amount)
        Payments::Mangopay::TransferPaymentWorker.perform_async(payout.id)
      end
    end

    private

    # Mangopay for now.
    def bookings_to_return_deposit
      bookings = Booking.includes(:payment, space: [venue: [:owner]])
        .joins("INNER JOIN mangopay_payments ON mangopay_payments.id = bookings.payment_id
                                                AND bookings.payment_type = 'MangopayPayment'")
        .joins('INNER JOIN spaces ON spaces.id = bookings.space_id')
        .joins('INNER JOIN venues ON venues.id = spaces.venue_id')
        .joins('INNER JOIN time_zones ON time_zones.id = venues.time_zone_id')
        .where('(NOT bookings.hold_deposit) AND mangopay_payments.deposit_amount_in_wallet > 0')
      verify_dates(bookings)
    end

    def verify_dates(bookings)
      bookings.where("(state = :paid AND (bookings.to +
        (interval '1 second' * time_zones.seconds_utc_difference)) <= :t) OR (
        (state = :cancelled OR state = :denied) AND (bookings.cancelled_at +
        (interval '1 second' * time_zones.seconds_utc_difference)) <= :t)",
                     paid: Booking.states[:paid], cancelled: Booking.states[:cancelled],
                     denied: Booking.states[:denied],
                     t: Time.current.advance(days: deposit_days * (-1)))
    end

    def deposit_days
      Rails.configuration.payment.deposit_days
    end

    def represented_user(represented)
      return represented if represented.is_a?(User)
      represented.users.first
    end
  end
end
