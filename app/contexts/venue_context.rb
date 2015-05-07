class VenueContext
  include BookingReservation

  def initialize(venue, current_represented)
    @venue = venue
    @current_represented = current_represented
    @old_day_hours = @venue.day_hours
  end

  def can_update?(new_days_hours)
    owner? && valid_venue_hours?(new_days_hours)
  end

  def owner?
    @current_represented.present? && @venue.owner == @current_represented
  end

  def can_update_venue_hours?(venue_params)
    can_update?(venue_params[:day_hours_attributes])
  end

  private

  def valid_venue_hours?(new_days_hours)
    return true unless reduce_venue_hours?(new_days_hours)
    date_from = @venue.time_zone.from_zone_to_utc(Time.current)
    no_bookings?(date_from)
  end

  def reduce_venue_hours?(new_days_hours)
    new_days_hours.values.each do |d|
      dh = @old_day_hours.select { |old_dh| old_dh.weekday == d[:weekday] }[0]
      return true unless check_venue_hour?(d[:from], d[:to], dh, d[:_destroy])
    end
    false
  end

  def check_venue_hour?(from, to, vh, destroy)
    return true if remove_day?(destroy, from, to, vh)
    reduce_hours?(from, to, vh)
  end

  def remove_day?(destroy, from, to, vh)
    destroy || (vh.present? && (from.empty? || to.empty?))
  end

  def reduce_hours?(from, to, vh)
    from.present? && to.present? && vh.present? &&
      !(from.to_i <= vh.from && to.to_i >= vh.to && from.to_i < to.to_i)
  end

  def no_bookings?(date_from)
    spaces_id = @venue.spaces.ids
    Booking.where do
      (space_id.in spaces_id) & (from >= date_from) & (state.in my { block_states })
    end.empty?
  end

end
