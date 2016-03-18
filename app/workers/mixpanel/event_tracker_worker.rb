require 'mixpanel-ruby'

module Mixpanel
  class EventTrackerWorker
    include Sidekiq::Worker

    def perform(user_id, event)
      user = User.find(user_id)
      return unless user && event

      user_ip = user.current_sign_in_ip.to_s

      mixpanel_tracker.track(user.id, event.to_s, {}, user_ip)
    end

    private

    def mixpanel_tracker
      Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    end
  end
end
