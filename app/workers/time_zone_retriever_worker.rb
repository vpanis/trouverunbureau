class TimeZoneRetrieverWorker
  include Sidekiq::Worker

  def perform(venue_id)
    venue = Venue.find(venue_id)
    timezone = Timezone::Zone.new(lat: venue.latitude, lon: venue.longitude)
    t = TimeZone.find_or_initialize_by(zone_identifier: timezone.zone)
    t.seconds_utc_difference = timezone.utc_offset
    t.save
    venue.update_attributes(time_zone: t, force_submit: true)
  rescue Timezone::Error::NilZone
    Rails.logger.error("Venue: #{venue_id} has an invalid latitude/longitude")
  end
end
