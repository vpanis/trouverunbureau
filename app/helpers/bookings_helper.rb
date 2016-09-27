module BookingsHelper
  def can_review?(booking, own = true)
    now = Time.current
    booking.space.persisted? && owner?(booking, own) && now >= booking.space.venue.time_zone.from_zone_to_utc(booking.from)
  end

  def can_view_receipt?(booking, own = true)
    owner?(booking, own)
  end

  def can_cancel?(booking, own = true)
    owner?(booking, own) && cancellable_states(booking) && !finished?(booking)
  end

  def can_delete?(booking, own = true)
    owner?(booking, own) && !deleted?(booking, own) && (booking.cancelled? || finished?(booking))
  end

  def can_make_claim?(booking, own = true)
    !venue_owner?(booking) && booking.space.venue.country_code == 'FR' && aig_claim_enabled_by_date?(booking)
  end

  def can_claim_deposit?(booking)
    venue_owner?(booking) && started?(booking) && !booking.hold_deposit &&
    booking.payment.present? && booking.payment.deposit_amount_in_wallet > 0
  end

  private

  def cancellable_states(booking)
    booking.paid? || booking.pending_authorization? || booking.pending_payment?
  end

  def finished?(booking)
    booking.space.persisted? && Time.current > booking.space.venue.time_zone.from_zone_to_utc(booking.to)
  end

  def started?(booking)
    booking.space.persisted? && Time.current > booking.space.venue.time_zone.from_zone_to_utc(booking.from)
  end

  def deleted?(booking, own = true)
    (own) ? booking.owner_delete? : booking.venue_owner_delete?
  end

  def owner?(booking, own = true)
    booking.space.persisted? && (own) ? booking.owner == current_represented : booking.space.venue.owner == current_represented
  end

  def venue_owner?(booking)
    booking.space.persisted? && booking.space.venue.owner == current_represented
  end

  def aig_claim_enabled_by_date?(booking)
    booking.payment.present? &&
    booking.payment.updated_at > (Date.strptime(ENV["AIG_CAN_MAKE_CLAIM_FROM_DATE"], '%Y-%m-%d') rescue Date.new(2016,9,1)) &&
    Time.current >= booking.space.venue.time_zone.from_zone_to_utc(booking.from)
  end
end
