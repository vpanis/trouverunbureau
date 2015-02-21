class UsersController < ApplicationController
  inherit_resources

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @gender_options = User::GENDERS.map { |g| [t("users.genders.#{g}"), g.to_s] }
    @profession_options = Venue::PROFESSIONS.map { |p| [t("venues.professions.#{p}"), p.to_s] }
    # TODO: define languages list
    @language_options = [[t('languages.es'), 'es'], [t('languages.en'), 'en']]
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes!(user_params)
    redirect_to edit_user_path(@user)
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :language, :avatar,
                                 :date_of_birth, :gender, :profession, :company_name)
  end

end
