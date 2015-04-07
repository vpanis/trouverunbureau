class OrganizationsController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper
  before_action :authenticate_user!, except: [:show]

  def show
    @user = Organization.find(params[:id])
    @organization_members = organization_members
    @owner = @organization_members.where(role: 0).first.user
    @can_edit = @user.eql?(current_represented)
  end

  def new
    @organization = Organization.new
  end

  def create
    organization = Organization.create(new_organization_params)
    organization.update_attributes!(user: current_user)
    redirect_to user_path(current_user)
  end

  def update
    @user = Organization.find(params[:id])
    return render_forbidden unless @user.eql?(current_represented)
    @user.update_attributes!(user_params)
    redirect_to organization_path(@user)
  end

  def edit
    @user = Organization.find(params[:id])
    @organization_members = organization_members
    @member_roles = OrganizationUser.roles.to_a
    byebug
    return render_forbidden unless @user.eql?(current_represented)
  end

  def destroy
    organization = Organization.find(params[:id])
    return render_forbidden unless organization.eql?(current_represented)
    organization.destroy!
    session[:current_organization_id] = nil
    redirect_to user_path(current_user)
  end

  private

  def user_params
    params.require(:organization).permit(:logo, :name, :email, :phone)
  end

  def organization_members
    OrganizationUser.where { organization_id.in [my { @user.id }] }.includes { [user] }
  end

  def show_represented(id, organization)
    return User.find(id) unless organization
    Organization.find(id)
  end

  def new_organization_params
    params.require(:organization).permit(:logo, :name, :email, :phone, :force_submit)
  end

end
