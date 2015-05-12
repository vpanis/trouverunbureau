class PerformPaymentsWorker
  include Sidekiq::Worker

  def perform
    bookings = bookings_to_pay
    bookings.each do |booking|
      payout = booking.payment.mangopay_payouts.create(amount: booking.price, fee: booking.fee)
      booking.payment.update_attributes(
        price_amount_in_wallet: booking.payment.price_amount_in_wallet - payout.amount,
        deposit_amount_in_wallet: booking.payment.deposit_amount_in_wallet - payout.fee)
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
      .where("(bookings.from + (interval '1 second' * time_zones.seconds_utc_difference)) <= :t",
             t: Time.current)
  end
end
