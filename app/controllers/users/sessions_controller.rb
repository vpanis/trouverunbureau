module Users
  class SessionsController < Devise::SessionsController
    def create
      super
      Mixpanel::EventTrackerWorker.perform_async(resource.id, 'Sign In')
    end
  end
end
