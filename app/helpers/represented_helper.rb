module RepresentedHelper

  def current_represented
    @current_represented if @current_represented
    nil if user_signed_in?

    @current_represented = current_user
    organization = Organization.find_by_id(session[:current_organization_id])
    @current_represented = organization if organization.present? &&
      current_user.user_can_write_in_name_of(organization)
    @current_represented
  end

end
