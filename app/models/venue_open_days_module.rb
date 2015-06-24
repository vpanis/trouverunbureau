module VenueOpenDaysModule
  def venue_opens_at_least_one_day_from_to?(from, to, v_hours)
    weekdays = VenueHour.days_covered(from, to)
    1 <= v_hours.where { weekday.eq_any weekdays }.group(:weekday).count.length
  end

  def venue_opens_days_from_to?(from, to, v_hours)
    weekdays = VenueHour.days_covered(from, to)
    weekdays.length == v_hours.where { weekday.eq_any weekdays }.group(:weekday).count.length
  end

  def venue_opens_hours_from_to?(from, to, v_hours)
    from_weekday = VenueHour.which_day(from)
    from = VenueHour.convert_time(from)
    to = VenueHour.convert_time(to)
    1 <= v_hours.where do
      (venue_hours.weekday == my { from_weekday }) &
      (venue_hours.from <= my { from }) &
      (venue_hours.to > my { to })
    end.count
  end
end
