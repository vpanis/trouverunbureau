class UsersController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper

  def show
    byebug
    @user = User.find(params[:id])
    @can_edit = @user.eql?(current_user)
    @can_view_reiews = user_can_read_client_reviews?(User, @user.id)
  end

  def edit
    @user = User.find(params[:id])
    return render_forbidden unless @user.eql?(current_user)
    @gender_options = gender_options
    @profession_options = profession_options
    @language_options = language_options
  end

  def update
    @user = User.find(params[:id])
    return render_forbidden unless @user.eql?(current_user)
    @user.update_attributes!(user_params)
    update_languages_spoken!
    redirect_to user_path(@user)
  end

  def login_as_organization
    organization = Organization.find_by(id: params[:organization_id])
    return record_not_found unless organization.present?
    return render nothing: true, status: 403 unless current_user.id == params[:id].to_i &&
    current_user.user_can_write_in_name_of(organization)
    session[:current_organization_id] = organization.id
    render session[:previous_url], status: 204
  end

  def reset_organization
    return forbidden unless current_user.id == params[:id].to_i
    session[:current_organization_id] = nil
    render session[:previous_url], status: 204
  end

  # TODO: implement account form and email notifications accordingly
  def account
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :language, :avatar,
                                 :date_of_birth, :gender, :profession, :company_name,
                                 :languages_spoken, :location, :interests, :emergency_relationship,
                                 :emergency_name, :emergency_email, :emergency_phone)
  end

  # sometimes the form sends "{'es'}" and we need to remove {}
  def update_languages_spoken!
    return unless  user_params['languages_spoken'].present?
    languages = user_params['languages_spoken'].gsub(/^\{+|\}+$/, '').split(',')
    @user.update_attributes!(languages_spoken: languages)
  end

end
