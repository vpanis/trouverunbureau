class VenueContext
  include BookingReservation

  def initialize(venue, current_represented)
    @venue = venue
    @current_represented = current_represented
    @day_hours = load_day_hours
  end

  def can_update?(days_hours)
    owner? && valid_venue_hours?(days_hours)
  end

  def owner?
    @current_represented.present? && @venue.owner == @current_represented
  end

  def update_venue?(venue_params)
    days_hours = venue_params[:day_hours_attributes]
    return false unless can_update?(days_hours)
    @venue.update_attributes!(venue_params)
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

  private

  def valid_venue_hours?(days_hours)
    return false unless well_formed_venue_hours?(days_hours)
    return true unless reduce_venue_hours?(days_hours)
    date_from = Time.zone.now.at_beginning_of_day - 1.day
    no_bookings?(date_from)
  end

  def well_formed_venue_hours?(days_hours)
    valid = true
    days_hours.values.each do |d|
      v = VenueHour.new(venue: @venue, from: d[:from], to: d[:to], weekday: d[:weekday])
      valid =  (v.valid?) unless d[:from].empty? && d[:to].empty?
      break unless valid
    end
    valid
  end

  def reduce_venue_hours?(days_hours)
    dangerous_change = false
    index = 0
    days_hours.values.each do |d|
      dh = @day_hours[index]
      dangerous_change = true  if check_venue_hour?(d[:from], d[:to], dh)
      index += 1
      break unless dangerous_change
    end
    dangerous_change
  end

  def check_venue_hour?(from, to, vh)
    return true if remove_day?(from, to, vh)
    reduce_hours?(from, to, vh)
  end

  def remove_day?(from, to, vh)
    vh.present? && (from.empty? || to.empty?)
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

  def load_day_hours
    day_hours = []
    @venue.day_hours.each do |dh|
      day_hours[dh.weekday] = dh
    end
    day_hours
  end

end
