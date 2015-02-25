class VenueContext

  def initialize(venue, current_represented)
    @venue = venue
    @current_represented = current_represented
  end

  def can_update?(days_from, days_to)
    owner? && valid_venue_hours?(days_from, days_to)
  end

  def owner?
    @current_represented.present? && @venue.owner == @current_represented
  end

  def update_venue?(venue_params, venue_hours_params)
    days_from = venue_hours_params[:day_from]
    days_to = venue_hours_params[:day_to]
    return false unless can_update?(days_from, days_to)
    @venue.update_attributes!(venue_params) && update_venue_hours!(days_from, days_to)
  end

  def valid_venue_hours?(days_from, days_to)
    load_day_hours
    return true unless reduce_venue_hours?(days_from, days_to)
    date_from = Time.zone.now.at_beginning_of_day - 1.day
    no_bookings?(date_from)
  end

  def update_venue_hours!(days_from, days_to)
    (0..6).each do |n|
      from = days_from[n].to_i if days_from[n].present?
      to = days_to[n].to_i if days_to[n].present?
      dh = @day_hours[n]
      if from.present? && to.present?
        save_venue_hour(from, to, dh, n)
      else
        delete_venue_hour(dh)
      end
    end
  end

  def reduce_venue_hours?(days_from, days_to)
    dangerous_change = false
    index = 0
    until index == 6 || dangerous_change
      from = days_from[index]
      to = days_to[index]
      dh = @day_hours[index]
      dangerous_change = true  if check_venue_hour?(from, to, dh)
      index += 1
    end
    dangerous_change
  end

  def check_venue_hour?(from, to, vh)
    from.present? && to.present? && vh.present? &&
    !(from.to_i <= vh.from && to.to_i >= vh.to && from.to_i < to.to_i)
  end

  def no_bookings?(date_from)
    spaces_id = @venue.spaces.ids
    Booking.where do
      (id.in spaces_id) & (from >= date_from) &
      (state.in Booking.states.values_at(:paid, :pending_payment))
    end.empty?
  end

  def load_day_hours
    @day_hours = []
    @venue.day_hours.each do |dh|
      @day_hours[dh.weekday] = dh
    end
  end

  def save_venue_hour(from, to, venue_hour, weekday)
    if venue_hour.present?
      venue_hour.update_attributes!(from: from, to: to)
    else
      VenueHour.create!(weekday: weekday, from: from, to: to, venue_id: @venue.id)
    end
  end

  def delete_venue_hour(venue_hour)
    VenueHour.delete(venue_hour) if venue_hour.present?
  end

end
