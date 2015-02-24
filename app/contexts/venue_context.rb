class VenueContext

  def initialize(venue, current_represented)
    @venue = venue
    @current_represented = current_represented
  end

  def can_update?
    owner? && valid_venue_hours?
  end

  def owner?
    @current_represented.present? && @venue.owner == @current_represented
  end

  def update_venue?(venue_params, venue_hours_params)
    # return false unless can_update?
    return false unless valid_venue_hours?(venue_hours_params)
    @venue.update_attributes!(venue_params)
  end

  def valid_venue_hours?(venue_hours_params)
    byebug
    @day_hours = []
    @venue.day_hours.each do |dh|
      @day_hours[dh.weekday] = dh
    end
    days_from = venue_hours_params[:day_from]
    days_to = venue_hours_params[:day_to]
    dangerous_change = false
    index = 0
    until(index == 6 || dangerous_change)
      from = days_from[index].to_i
      to = days_to[index].to_i
      dh = @day_hours[index]
      if(from.present? && to.present? && dh.present?)
        if(!(from<= dh.from && to>= dh.to))
          dangerous_change = true
        end
      end
      index+=1
    end
    return true unless dangerous_change
    date_from = Time.zone.now.at_beginning_of_day - 1.day
    no_bookings?(date_from)
  end

  def no_bookings?(date_from)
    spaces_id = @venue.spaces.ids
    Booking.where { (id.in spaces_id) & (from >= date_from) & (state == Booking.states["paid"] ||
      state == Booking.states["pending_payment"]) }.empty?
  end
end
