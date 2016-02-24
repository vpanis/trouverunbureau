class TimeZone < ActiveRecord::Base
  has_many :venues

  validates :zone_identifier, :seconds_utc_difference, presence: true
  validates :zone_identifier, uniqueness: { case_sensitive: false }
  validates :seconds_utc_difference, numericality: { only_integer: true }

  def from_zone_to_utc(time)
    zt_timezone.utc_to_local(time)
  end

  private

  def zt_timezone
    @zt_timezone ||= Timezone::Zone.new(zone: zone_identifier)
  end

end
