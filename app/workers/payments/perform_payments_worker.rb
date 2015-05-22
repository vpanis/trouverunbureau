module Payments
  class PerformPaymentsWorker
    include Sidekiq::Worker

    def perform
      bookings = bookings_to_pay
      bookings.each do |booking|
        payout_attributes, next_payout_at = payout_attributes_and_next_payout(booking)
        payout = booking.payment.mangopay_payouts.create(payout_attributes)
        booking.payment.update_attributes(
          next_payout_at: next_payout_at,
          price_amount_in_wallet: booking.payment.price_amount_in_wallet - payout.amount)
        Payments::Mangopay::TransferPaymentWorker.perform_async(booking.id, payout.id)
      end
    end

    # Mangopay for now.
    def bookings_to_pay
      Booking.includes(:payment)
        .joins("INNER JOIN mangopay_payments ON mangopay_payments.id = bookings.payment_id
                                                AND bookings.payment_type = 'MangopayPayment'")
        .joins('INNER JOIN spaces ON spaces.id = bookings.space_id')
        .joins('INNER JOIN venues ON venues.id = spaces.venue_id')
        .joins('INNER JOIN time_zones ON time_zones.id = venues.time_zone_id')
        .where('state = :paid', paid: Booking.states[:paid])
        .where('mangopay_payments.price_amount_in_wallet > 0')
        .where("(mangopay_payments.next_payout_at +
          (interval '1 second' * time_zones.seconds_utc_difference)) <= :t", t: Time.current)
    end

    def payout_attributes_and_next_payout(booking)
      future_payout_at = booking.payment.next_payout_at.advance(months: 1)
      future_payout_at = booking.to if booking.to <= future_payout_at
      amount = calculate_amount(booking, future_payout_at)
      [{ amount: amount,
         fee: calculate_fee(amount),
         p_type: MangopayPayout.p_types[:payout_to_user] },
       future_payout_at]
    end

    def calculate_amount(booking, future_payout_at)
      return booking.payment.price_amount_in_wallet if booking.to <= future_payout_at
      percentage_price(booking.payment.next_payout_at, booking.to, future_payout_at,
                       booking.payment.price_amount_in_wallet)
      # In more than one variable to clarify things
      days_left_to_pay = (booking.to - booking.payment.next_payout_at) / 1.day
      days_in_this_payout = (future_payout_at - booking.payment.next_payout_at) / 1.day
      floor_2d(days_in_this_payout / days_left_to_pay * booking.payment.price_amount_in_wallet)
    end

    # This will have variable fees in the future
    def calculate_fee(price)
      floor_2d(price * Rails.configuration.payment.deskspotting_fee)
    end

    def floor_2d(float)
      (float * 100).floor / 100.0
    end
  end
end
