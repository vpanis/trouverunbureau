require 'mixpanel-ruby'

module Mixpanel
  class SignUpTrackerWorker
    include Sidekiq::Worker

    def perform(user_id)
      user = User.find(user_id)
      return unless user

      user_ip = user.current_sign_in_ip.to_s

      mixpanel_tracker.people.set(user.id, user_info_to_track(user), user_ip)
      mixpanel_tracker.track(user.id, 'Sign Up', {}, user_ip)
    end

    private

    def mixpanel_tracker
      Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])
    end

    def user_info_to_track(user)
      # Take a look on mixpanel special properties
      # https://mixpanel.com/help/reference/http#people-special-properties

      info = user.attributes.symbolize_keys
      info = info.slice(:first_name, :last_name, :email).transform_keys { |k| "$#{k}" }
      info['$created'] = user.created_at
      info['Country of Residence'] = Country.new(user[:country_of_residence]).name
      info
    end
  end
end
