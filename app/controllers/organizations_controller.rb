class OrganizationsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper

  def show
#    @organization = (params[:organization].present? && params[:organization]) ? true : false
#    @user = show_represented(params[:id], @organization)
#    @organization_members = organization_members if @user.is_a?(Organization)
#    @owner = @organization_members.where(role: 0).first.user if @user.is_a?(Organization)
#    @can_edit = @user.eql?(current_represented)
#    @can_view_reiews = user_can_read_client_reviews?(User, @user.id)
  end

  def new
    @organization = Organization.new
  end

  def create
    organization = Organization.create(new_organization_params)
    byebug
    organization.update_attributes!(user: current_user)
    redirect_to user_path(current_user)
  end

  def update
    @user = Organization.find(params[:id])
    return render_forbidden unless @user.eql?(current_represented)
    @user.update_attributes!(user_params)
    redirect_to user_path(@user, organization: true)
  end

  def edit
    @user = Organization.find(params[:id])
    return render_forbidden unless @user.eql?(current_represented)
  end

  def login_as_organization
    organization = Organization.find(params[:organization_id])
    return render_forbidden unless current_user.id == params[:id].to_i &&
    current_user.user_can_write_in_name_of(organization)
    session[:current_organization_id] = organization.id
    redirect_to session[:previous_url] || root_path
  end

  def reset_organization
    return render_forbidden unless current_user.id == params[:id].to_i
    session[:current_organization_id] = nil
    redirect_to session[:previous_url] || root_path
  end


  private

  def user_params
    params.require(:organization).permit(:name, :email, :phone)
  end

  def organization_members
    OrganizationUser.where { id.in [my { @user.id }] }.includes { [user] }
  end

  def show_represented(id, organization)
    user = User.find(id) unless organization
    user = Organization.find(id) if organization
    user
  end

  def new_organization_params
    params.require(:organization).permit(:name, :email, :phone, :force_submit)
  end

end
