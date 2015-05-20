class RefreshReferralStatsJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    ReferralStat.refresh_view
  end
end
