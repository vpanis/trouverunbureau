module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json
      before_action :authenticate_user!, only: [:client_reviews]

      def login_as_organization
        organization = Organization.find_by(id: params[:organization_id])
        return render nothing: true, status: 404 unless organization.present?
        return render nothing: true, status: 403 unless current_user.id == params[:id].to_i &&
          current_user.user_can_write_in_name_of(organization)
        session[:current_organization_id] = organization.id
        render nothing: true, status: 204
      end

      def reset_organization
        return render nothing: true, status: 403 unless current_user.id == params[:id].to_i
        session[:current_organization_id] = nil
        render nothing: true, status: 204
      end
    end
  end
end
