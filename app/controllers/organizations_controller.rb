class OrganizationsController < ApplicationController
  inherit_resources
  include SelectOptionsHelper
  before_action :authenticate_user!, except: [:show]

  def show
    @organization = Organization.find(params[:id])
    @organization_members = organization_members
    @owner = @organization_members.where(role: 0).first.user
    @can_edit = @organization.eql?(current_represented)
  end

  def new
    @organization = Organization.new
  end

  def create
    organization = Organization.create(new_organization_params)
    organization.update_attributes!(user: current_user)
    create_mangopay_payment_account(organization)
    redirect_to user_path(current_user)
  end

  def update
    @organization = Organization.find(params[:id])
    return render_forbidden unless @organization.eql?(current_represented)
    @organization.update_attributes!(user_params)
    redirect_to organization_path(@organization)
  end

  def edit
    @organization = Organization.find(params[:id])
    @organization_members = organization_members
    @member_roles = OrganizationUser.roles.to_a
    return render_forbidden unless @organization.eql?(current_represented)
  end

  private

  def user_params
    params.require(:organization).permit(:logo, :name, :email, :phone)
  end

  def organization_members
    OrganizationUser.where { organization_id.eq my { @organization.id } }.includes { [user] }
  end

  def organization_member(id, member_id)
    OrganizationUser.where { (organization_id.eq my { id }) & (user_id.eq my { member_id }) }
  end

  def show_represented(id, organization)
    return User.find(id) unless organization
    Organization.find(id)
  end

  def new_organization_params
    params.require(:organization).permit(:logo, :name, :email, :phone, :force_submit)
  end

  def create_mangopay_payment_account(organization)
    mpa = MangopayPaymentAccount.create(buyer: organization,
                                        status: MangopayPaymentAccount.statuses[:processing])
    Payments::Mangopay::PaymentAccountWorker.perform_async(current_user.id, mpa.id)
  end

end
