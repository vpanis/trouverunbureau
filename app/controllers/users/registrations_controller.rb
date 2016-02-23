module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      super
      return unless resource.persisted? # user is created successfuly
    end
  end
end
