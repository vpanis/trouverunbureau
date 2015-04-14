module Api
  module V1
    class OrganizationUsersController < ApplicationController
      include RepresentedHelper

      def index
        @organization = Organization.find(params[:organization_id])
        render status: 200, json: organization_members,
               each_serializer: OrganizationUserSerializer, root: false
      end

      def create
        user = User.find_by(email: params[:email])
        organization = Organization.find(params[:organization_id])
        return record_not_found unless user.present?
        unless current_represented == organization || organization.user_in_organization?(user)
          return render status: 403, nothing: true
        end
        member = OrganizationUser.create!(user: user, organization: organization,
                                          role: params[:role].to_i)
        render status: 201, json: member, serializer: OrganizationUserSerializer, root: false
      end

      def destroy
        organization = Organization.find(params[:organization_id])
        return render status: 403, nothing: true unless current_represented == organization
        organization_user = OrganizationUser.find(params[:id])
        organization_user.destroy!
        if organization_user.user == current_user
          session[:current_organization_id] = nil
          return render status: 200, json: { redirect_url: user_path(current_user) }
        end
        render status: 204, nothing: true
      end

      private

      def organization_members
        OrganizationUser.where { organization_id.in [my { @organization.id }] }.includes { [user] }
      end
    end
  end
end
