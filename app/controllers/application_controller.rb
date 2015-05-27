class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  serialization_scope :view_context

  after_action :set_csrf_cookie_for_ng, :store_location

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    render text: "Required parameter missing: #{parameter_missing_exception.param}",
           status: :bad_request
  end

  after_action :set_user_language

  def set_user_language
    return I18n.locale = params[:locale] if params[:locale].present? && current_user.nil?
    I18n.locale = current_user.language if current_user.present? && current_user.language.present?
  end

  def default_url_options
    default = super || {}
    default[:locale] = params[:locale] if params[:locale].present?
    default
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def after_sign_in_path_for(_resource)
    return root_path if session[:previous_url].start_with?('/users/auth/facebook')
    session[:previous_url] || root_path
  end

  private

  # store last url - this is needed for post-login redirect to whatever the user last visited.
  def store_location
    return unless request.get?
    session[:previous_url] = request.fullpath unless ignorable_request? || api_request?
  end

  def ignorable_request?
    request.path == '/users/sign_in' || request.path == '/users/sign_up' ||
    request.path == '/users/password/new' || request.path == '/users/sign_out' ||
    request.path == '/users/password/edit'
  end

  def api_request?
    request.path.start_with?('/api/') || request.xhr?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :first_name, :last_name, :password, :remember_me, :date_of_birth,
               :nationality, :country_of_residence, :provider)
    end

    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  def render_forbidden
    return redirect_to flash[:redirect_if_403] if flash[:redirect_if_403].present?
    render file: "#{Rails.root}/public/403", layout: false, status: 403
  end

  def record_not_found
    # TODO: improve
    render file: "#{Rails.root}/public/404", layout: false, status: 404
  end

end
