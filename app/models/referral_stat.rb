class ReferralStat < ActiveRecord::Base
  belongs_to :venue
  self.primary_key = 'venue_id'

  def readonly?
    true
  end

  def self.refresh_view
    connection = ActiveRecord::Base.connection
    connection.execute('REFRESH MATERIALIZED VIEW referral_stats')
  end
end
