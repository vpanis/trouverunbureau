module Users
  class InvitationsController < Devise::InvitationsController
    include RepresentedHelper

    protected
    def current_inviter
      current_represented
    end
  end
end
