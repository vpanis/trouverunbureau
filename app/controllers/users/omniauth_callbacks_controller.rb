module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def facebook
      @user = User.from_omniauth(request.env['omniauth.auth'])
      if @user.new_record?
        render 'devise/registrations/new', layout: 'session'
      else
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
      end
    end
  end
end
