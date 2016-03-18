require 'mixpanel-ruby'

module Mixpanel
  class EventTrackerWorker
    include Sidekiq::Worker

    def perform(user_id, event)
      return unless user_id && event
      mixpanel_tracker.track(user_id.to_s, event.to_s)
    end

    private

    def mixpanel_tracker
      Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    end
  end
end
