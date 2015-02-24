class UsersController < ApplicationController
  inherit_resources
  include RepresentedHelper

  def show
    @user = User.find(params[:id])
    @can_edit = @user.eql?(current_user)
    @can_view_reiews = user_can_read_client_reviews?(User, @user.id)
  end

  def edit
    @user = User.find(params[:id])
    return render nothing: true, status: 403 unless @user.eql?(current_user)
    @gender_options = User::GENDERS.map { |g| [t("users.genders.#{g}"), g.to_s] }
    @profession_options = Venue::PROFESSIONS.map { |p| [t("venues.professions.#{p}"), p.to_s] }
    # TODO: define languages list
    @language_options = [[t('languages.es'), 'es'], [t('languages.en'), 'en']]
  end

  def update
    @user = User.find(params[:id])
    # TODO: redirect to custom 403 page
    return render nothing: true, status: 403 unless @user.eql?(current_user)
    @user.update_attributes!(user_params)
    redirect_to edit_user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :language, :avatar,
                                 :date_of_birth, :gender, :profession, :company_name)
  end

end
