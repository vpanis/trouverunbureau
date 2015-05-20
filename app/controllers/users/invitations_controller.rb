module Users
  class InvitationsController < Devise::InvitationsController
    include RepresentedHelper

    def create
      if user_exists?
        flash['error'] = 'user_exists'
        self.resource = resource_class.new(email: params[:user][:email])
      else
        super
      end
    end

    protected

    def user_exists?
      User.exists?(email: params[:user][:email])
    end

    def current_inviter
      current_represented
    end
  end
end
