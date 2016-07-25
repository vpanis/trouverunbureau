module Payments
  class PerformPaymentsWorker
    include Sidekiq::Worker
    include Sidetiq::Schedulable

    recurrence { hourly }

    def perform
      bookings = bookings_to_pay
      bookings.each do |booking|
        payout_attributes, next_payout_at = payout_attributes_and_next_payout(booking)
        payout = booking.payment.mangopay_payouts.create(payout_attributes)
        fill_receipt(payout, booking)
        booking.payment.update_attributes(
          next_payout_at: next_payout_at,
          price_amount_in_wallet: booking.payment.price_amount_in_wallet - payout.amount)
        Payments::Mangopay::TransferPaymentWorker.perform_async(payout.id)
      end
    end

    # Mangopay for now.
    def bookings_to_pay
      Booking.includes(:payment, :owner, space: [venue: [:collection_account]])
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
         fee: calculate_fee(amount, booking),
         user_id: booking.payment.user_paying_id,
         represented: booking.owner,
         p_type: MangopayPayout.p_types[:payout_to_user] },
       future_payout_at]
    end

    def calculate_amount(booking, future_payout_at)
      return booking.payment.price_amount_in_wallet if booking.to <= future_payout_at
      # In more than one variable to clarify things
      days_left_to_pay = (booking.to - booking.payment.next_payout_at) / 1.day
      days_in_this_payout = (future_payout_at - booking.payment.next_payout_at) / 1.day
      floor_2d(days_in_this_payout / days_left_to_pay * booking.payment.price_amount_in_wallet)
    end

    def calculate_fee(price, booking)
      # Minimum Time Frame 1 month = 20% for 1st month - 5% per month thereafter.
      # Minimum Time Frame 2 months = 20% for 1st month 10% 2nd month - 5% per month thereafter
      # Minimum Time Frame 3 months = 20% for 1st month, 10% 2nd month, 10% 3rd month, 5% thereafter.
      # The minimum time frame on Month to Month Bookings cannot exceed 3 months.

      fee_rate = PayConf.deskspotting_fee2

      if (%w(month month_to_month).include? booking.b_type)
        m2mmu = booking.space.month_to_month_minimum_unity
        next_payout_at = booking.payment.try(:next_payout_at) || Date.today

        fee_rate =  if next_payout_at == booking.from
                      # first payout
                      PayConf.deskspotting_fee
                    elsif next_payout_at <= booking.from.advance(months: m2mmu)
                      PayConf.deskspotting_fee2
                    else
                      PayConf.deskspotting_fee3
                    end
      end

      floor_2d(fee_rate * price)
    end

    def floor_2d(float)
      (float * 100).floor / 100.0
    end

    def fill_receipt(payout, booking)
      cc = booking.space.venue.collection_account
      Receipt.create(payment: payout, bank_type: cc.bank_type,
                     account_last_4: cc.generic_account_last_4)
    end
  end
end
