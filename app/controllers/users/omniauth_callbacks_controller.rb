module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    def facebook
      @user = User.from_omniauth(request.env['omniauth.auth'])
      @new_user_from_facebook = !@user.persisted?
      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Facebook') if is_navigational_format?
      else
        render 'devise/registrations/new', layout: 'session' if @user.new_record?
      end
    end
  end
end
