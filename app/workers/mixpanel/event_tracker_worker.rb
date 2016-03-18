require 'mixpanel-ruby'

module Mixpanel
  class EventTrackerWorker
    include Sidekiq::Worker

    def perform(user_id, event)
      user = User.find(user_id)
      return unless user && event

      mixpanel_tracker.track(user.id, event, {}, user.current_sign_in_ip)
    end

    private

    def mixpanel_tracker
      Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    end
  end
end
