class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  serialization_scope :view_context

  after_action :set_csrf_cookie_for_ng, :store_location

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def after_sign_in_path_for(resource)
    path = request.env['omniauth.origin'] || session[:previous_url] || root_path
    # TODO: change this for search view
    return user_path(resource) if path == root_path
    path
  end

  private

  # store last url - this is needed for post-login redirect to whatever the user last visited.
  def store_location
    return unless request.get?
    session[:previous_url] = request.fullpath unless ignorable_request?
  end

  def ignorable_request?
    request.path == '/users/sign_in' || request.path == '/users/password/new' ||
    request.path == '/users/password/edit' || request.path == '/users/sign_out' ||
    request.xhr? # don't store ajax calls
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :first_name, :last_name, :password, :remember_me)
    end

    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  def render_forbidden
    # TODO: improve
    render file: "#{Rails.root}/public/403", layout: false, status: 403
  end

end
