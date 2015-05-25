module Payments
  class CancellationWorker
    include Sidekiq::Worker

    def perform(booking_id, user_id, represented_id, represented_type)
      init_log(booking_id, user_id, represented_id, represented_type)
      @booking = Booking.find_by(id: booking_id, state: Booking.states[:refunding])
      @represented = represented_type.constantize.find_by_id(represented_id)
      return unless valid_data?
      @time_zone = @booking.space.venue.time_zone
      return_the_payment(user_id)
    end

    private

    def init_log(booking_id, user_id, represented_id, represented_type)
      str = "Payments::CancellationWorker on booking_id: #{booking_id}, "
      str += "user_id: #{user_id}, represented_id: #{represented_id}, "
      str += "represented_type: #{represented_type}"
      Rails.logger.info(str)
    end

    def valid_data?
      @booking.present? && @represented.present? && @booking.payment.present? &&
        @booking.payment.payin_succeeded?
    end

    def return_the_payment(user_id)
      from_in_current = @time_zone.from_zone_to_utc(@booking.from)
      current = Time.current
      return refund(@booking.price, user_id, true) if all_refund?(from_in_current, current)
      return more_than_a_month_cancellation(user_id) if partial_refund?(from_in_current, current)
      return payout_to_user(@booking.price, @booking.fee, user_id) if
        state_if_represented_cancels(@represented) == Booking.states[:cancelled]
      refund(@booking.payment.price_amount_in_wallet, user_id, false) if
        @booking.payment.price_amount_in_wallet > 0 # To not enqueue a refund of 0
    end

    def more_than_a_month_cancellation(user_id)
      refund(
        ceil_2d(@booking.price * (1 - cancellation.percentage_to_the_venue_in_more_than_a_month)),
        user_id, true)
      # for the @booking.payment.update_attributes
      @booking.reload
      payout_to_user(
        floor_2d(@booking.price * cancellation.percentage_to_the_venue_in_more_than_a_month),
        floor_2d(@booking.fee * cancellation.percentage_to_the_venue_in_more_than_a_month),
        user_id)
    end

    def refund(amount, user_id, with_deposit)
      amount += @booking.deposit if with_deposit
      payout = @booking.payment.mangopay_payouts.create(amount: amount, fee: 0, user_id: user_id,
                                                        represented: @represented,
                                                        p_type: MangopayPayout.p_types[:refund])
      payment_attributes = {
        price_amount_in_wallet: booking.payment.price_amount_in_wallet - payout.amount }
      payment_attributes[:deposit_amount_in_wallet] = 0 if with_deposit
      @booking.payment.update_attributes(payment_attributes)
      Payments::Mangopay::RefundPayinWorker.perform_async(payout.id)
    end

    def payout_to_user(amount, fee, user_id)
      payout = @booking.payment.mangopay_payouts.create(amount: amount, fee: fee, user_id: user_id,
                 p_type: MangopayPayout.p_types[:payout_to_user], represented: @represented)
      @booking.payment.update_attributes(
        price_amount_in_wallet: booking.payment.price_amount_in_wallet - payout.amount)
      Payments::Mangopay::TransferPaymentWorker.perform_async(payout.id)
    end

    def partial_refund?(from_in_current, current)
      return false if @booking.from.advance(months: 1, seconds: -1) > @booking.to
      from_in_current <= current.advance(hours: cancellation.more_that_a_month_in_hours) &&
        from_in_current > current
    end

    def all_refund?(from_in_current, current)
      return from_in_current > current.advance(hours: cancellation.less_than_24_hours_in_hours) if
        @booking.hour?
      # month in booking is from dd/mm 00:00:00 to dd/(mm+1) 23:59:59
      return from_in_current > current.advance(hours: cancellation.less_than_a_month_in_hours) if
        @booking.from.advance(months: 1, seconds: -1) > @booking.to
      from_in_current > current.advance(hours: cancellation.more_than_a_month_in_hours)
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
