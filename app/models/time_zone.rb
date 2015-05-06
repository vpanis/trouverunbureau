class TimeZone < ActiveRecord::Base
  has_many :venues

  validates :zone_identifier, :minute_utc_difference, presence: true
  validates :zone_identifier, uniqueness: { case_sensitive: false }
  validates :minute_utc_difference, numericality: { only_integer: true }
end
