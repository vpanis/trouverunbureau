module Api
  module V1
    class OrganizationUsersController < ApplicationController
      def index
        @organization = Organization.find(params[:organization_id])
        render status: 200, json: organization_members,
               each_serializer: OrganizationUserSerializer, root: false
      end

      def create
        user = User.find_by(email: params[:email])
        organization = Organization.find(params[:organization_id])
        return record_not_found unless user.present?
        unless available_to_create(organization)
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
        OrganizationUser.where { organization_id.eq my { @organization.id } }.includes { [user] }
      end

      def available_to_create(organization)
        current_represented == organization || organization.user_in_organization(current_user)
      end
    end
  end
end
