class ConfigurationsController < ApplicationController

  def change_language
    params[:languange] = params[:languange].to_sym if params[:languange].present?
    current_user.update_attributes(params[:language]) if
      User::LANGUAGES.include?(params[:languange])
    session[:locale] = params[:language]
    redirect_to :back
  end
end
