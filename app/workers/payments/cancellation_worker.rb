module Payments
  class CancellationWorker
    include Sidekiq::Worker

    def perform(booking_id, user_id, represented_id, represented_type)
      @booking = Booking.find_by(id: booking_id, state: Booking.states[:refunding])
      @represented = represented_type.constantize.find_by_id(represented_id)
      return if invalid_data?
      @time_zone = @booking.space.venue.time_zone
      return_the_payment(user_id)
    end

    private

    def invalid_data?
      @booking.present? && @represented.present?
    end

    def return_the_payment(user_id)
      from_in_current = @time_zone.from_zone_to_utc(@booking.from)
      current = Time.current
      return refund(@booking.price, user_id) if all_refund?(from_in_current, current)
      return more_than_a_month_cancellation(user_id) if partial_refund?(from_in_current, current)
      payout_to_user(@booking.price, @booking.fee)
    end

    def more_than_a_month_cancellation(user_id)
      refund(
        ceil_2d(@booking.price * (1 - cancellation.percentage_to_the_venue_in_more_than_a_month)),
        user_id)
      # for the @booking.payment.update_attributes
      @booking.reload
      payout_to_user(
        floor_2d(@booking.price * cancellation.percentage_to_the_venue_in_more_than_a_month),
        floor_2d(@booking.fee * cancellation.percentage_to_the_venue_in_more_than_a_month))
    end

    def refund(amount, user_id)
      payout = @booking.payment.mangopay_payouts.create(amount: amount, fee: 0,
                                                        p_type: MangopayPayout.p_types[:refund])
      @booking.payment.update_attributes(
          price_amount_in_wallet: booking.payment.price_amount_in_wallet - payout.amount)
      Payments::Mangopay::RefundPayinWorker.perform_async(@booking.id, payout.id, user_id,
                                                          @represented.id, @represented.class.to_s)
    end

    def payout_to_user(amount, fee)
      payout = @booking.payment.mangopay_payouts.create(amount: amount, fee: fee,
                 p_type: MangopayPayout.p_types[:payout_to_user])
      @booking.payment.update_attributes(
        price_amount_in_wallet: booking.payment.price_amount_in_wallet - payout.amount)
      Payments::Mangopay::TransferPaymentWorker.perform_async(@booking.id, payout.id)
    end

    def partial_refund?(from_in_current, current)
      return false if @booking.from.advance(months: 1, seconds: -1) > @booking.to
      from_in_current <= current.advance(hours: cancellation.more_that_a_month_in_hours) &&
        from_in_current > current
    end

    def all_refund?(from_in_current, current)
      return from_in_current > current.advance(hours: cancellation.less_that_24_hours_in_hours) if
        @booking.hour?
      # month in booking is from dd/mm 00:00:00 to dd/(mm+1) 23:59:59
      return from_in_current > current.advance(hours: cancellation.less_that_a_month_in_hours) if
        @booking.from.advance(months: 1, seconds: -1) > @booking.to
      from_in_current > current.advance(hours: cancellation.more_that_a_month_in_hours)
    end

    def cancellation
      Rails.configuration.payment.cancellation
    end

    def ceil_2d(float)
      (float * 100).ceil / 100.0
    end

    def floor_2d(float)
      (float * 100).floor / 100.0
    end
  end
end
