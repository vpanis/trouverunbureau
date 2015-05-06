class AddTimeZoneToVenues < ActiveRecord::Migration
  def change
    add_reference :venues, :time_zone, index: true
  end
end
