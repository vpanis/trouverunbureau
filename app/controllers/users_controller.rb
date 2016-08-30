class UsersController < ApplicationController
  inherit_resources
  include SelectOptionsHelper
  before_action :authenticate_user!, except: [:show]

  def show
    @user = User.find(params[:id])
    @can_edit = @user.eql?(current_represented)
    @can_view_reviews = user_can_read_client_reviews?(User, @user.id)
  end

  def edit
    @user = User.find(params[:id])
    return render_forbidden unless @user.eql?(current_represented)
    @gender_options = gender_options
    @profession_options = profession_options
    @language_options = language_options
    @all_language_options = all_language_options
  end

  def update
    @user = User.find(params[:id])
    return render_forbidden unless @user.eql?(current_represented)
    @user.update_attributes!(user_params)
    update_languages_spoken!
    redirect_to user_path(@user)
  end

  def login_as_organization
    organization = Organization.find(params[:organization_id])
    return render_forbidden unless current_user.id == params[:id].to_i &&
      current_user.user_can_write_in_name_of(organization)
    session[:current_organization_id] = organization.id
    flash[:redirect_if_403] = organization_path(current_represented)
    redirect_to session[:previous_url] || root_path
  end

  def reset_organization
    return render_forbidden unless current_user.id == params[:id].to_i
    session[:current_organization_id] = nil
    flash[:redirect_if_403] = user_path(current_represented)
    redirect_to session[:previous_url] || root_path
  end

  def update_account_settings
    current_user.update_attributes!(settings: settings_params[:settings])
    redirect_to account_user_path(current_user)
  end

  def confirm_identity
    return render_forbidden unless current_user.admin?

    @user = User.find(params[:id])
    @user.update_attributes!(identity_confirmed: true)

    redirect_to admin_users_path
  end

  private

  def settings_params
    params.require(:user).permit(
      settings: [:person_message, :incoming_inquiry, :accepted_inquiry, :account_changes]
    )
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :language, :avatar, :identity_picture,
                                 :date_of_birth, :nationality, :country_of_residence, :gender,
                                 :profession, :company_name, :languages_spoken, :location,
                                 :interests, :emergency_relationship, :emergency_name,
                                 :emergency_email, :emergency_phone)
  end

  # sometimes the form sends "{'es'}" and we need to remove {}
  def update_languages_spoken!
    return unless user_params['languages_spoken'].present?
    languages = user_params['languages_spoken'].gsub(/^\{+|\}+$/, '').split(',')
    @user.update_attributes!(languages_spoken: languages)
  end

  def organization_members
    OrganizationUser.where { organization_id.in [my { @user.id }] }.includes { [user] }
  end
end
