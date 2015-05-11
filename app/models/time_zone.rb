class TimeZone < ActiveRecord::Base
  has_many :venues

  validates :zone_identifier, :seconds_utc_difference, presence: true
  validates :zone_identifier, uniqueness: { case_sensitive: false }
  validates :seconds_utc_difference, numericality: { only_integer: true }

  # Recieves a utc time, and adds it the difference with this zone
  # Example:
  # t = Time.current = Wed, 06 May 2015 21:54:09 UTC +00:00
  # in zone Buenos Aires (-3:00)
  # from_zone_to_utc(t) = 2015-05-07 00:54:09 UTC
  def from_zone_to_utc(time)
    zt_timezone.utc_to_local(time)
  end

  private

  def zt_timezone
    @zt_timezone = Timezone::Zone.new(zone: zone_identifier) unless @zt_timezone.present?
    @zt_timezone
  end

end
