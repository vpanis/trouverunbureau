module Api
  module V1
    class AuthenticatedApiController < ApplicationController
      serialization_scope :user
      attr_reader :user

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      protected

      def validate_user
        @token = request.headers[:HTTP_SESSION_TOKEN]
        @user = User.find_by(session_token: @token) unless @token.blank?
        render status: 401, nothing: true if @user.blank?
      end

      def record_not_found
        render status: 404, nothing: true
      end

      def wrong_preconditions
        render status: 412, nothing: true
      end

      def render_nothing
        render status: 204, nothing: true
      end
    end
  end
end
