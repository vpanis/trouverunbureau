class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token, if: :json_request?

  before_action :configure_permitted_parameters, if: :devise_controller?

  serialization_scope :view_context

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_not_found

  private

  def json_request?
    request.format.json?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :first_name, :last_name, :password, :remember_me)
    end

    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
  end

  def redirect_to_not_found
    # TODO: redirect to custom 404 page
    redirect_to root_path
  end

end
