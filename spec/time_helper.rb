def advance_in_time(time_attributes_to_advance)
  Timecop.travel(Time.current.advance(time_attributes_to_advance))
end
