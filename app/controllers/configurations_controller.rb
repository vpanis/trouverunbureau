class ConfigurationsController < ApplicationController

  def change_language
    return unless User::LANGUAGES.map(&:to_s).include?(params[:language].to_s)
    current_user.update_attributes(language: params[:language]) if current_user.present?
    session[:locale] = params[:language]
    redirect_to :back, status: 303
  end
end
