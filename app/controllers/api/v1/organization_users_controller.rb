module Api
  module V1
    class OrganizationUsersController < ApplicationController
      def index
        @user = Organization.find(params[:organization_id])
        render status: 200, json: organization_members,
               each_serializer: OrganizationUserSerializer, root: false
      end

      def create
        user = User.find_by(email: params[:email])
        return record_not_found unless user.present?
        member = OrganizationUser.create!(user: user, organization_id: params[:organization_id],
                                          role: params[:role].to_i)
        render status: 201, json: member, serializer: OrganizationUserSerializer, root: false
      end

      def destroy
        OrganizationUser.find(params[:id]).destroy!
        render status: 200, nothing: true
      end

      private

      def organization_members
        OrganizationUser.where { organization_id.in [my { @user.id }] }.includes { [user] }
      end
    end
  end
end
