module Api
  module V1
    class UsersController < ApiController
      before_action :authenticate_user!, except: [:basic_info]

      def login_as_organization
        organization = Organization.find_by(id: params[:organization_id])
        return record_not_found unless organization.present?
        return render nothing: true, status: 403 unless current_user.id == params[:id].to_i &&
          current_user.user_can_write_in_name_of(organization)
        session[:current_organization_id] = organization.id
        render nothing: true, status: 204
      end

      def reset_organization
        return forbidden unless current_user.id == params[:id].to_i
        session[:current_organization_id] = nil
        render nothing: true, status: 204
      end

      def basic_info
        user = User.find_by(email: params[:email])
        return record_not_found unless user.present?
        render json: user, serializer: UserSerializer, status: 200
      end

    end
  end
end
