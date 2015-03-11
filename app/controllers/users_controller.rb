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
    return render_forbidden unless @user.eql?(current_user)
    @gender_options = User::GENDERS.map { |g| [t("users.genders.#{g}"), g.to_s] }
    @profession_options = Venue::PROFESSIONS.map { |p| [t("venues.professions.#{p}"), p.to_s] }
    # TODO: define languages list
    @language_options = [[t('languages.es'), 'es'], [t('languages.en'), 'en'],
                         [t('languages.de'), 'de'], [t('languages.it'), 'it']]
  end

  def update
    @user = User.find(params[:id])
    return render_forbidden unless @user.eql?(current_user)
    @user.update_attributes!(user_params)
    update_languages_spoken!
    redirect_to user_path(@user)
  end

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
