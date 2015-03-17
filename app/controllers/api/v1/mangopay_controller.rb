module Api
  module V1
    class MangopayController < ApplicationController
      include RepresentedHelper
      before_action :authenticate_user!, only: [:configuration]

      def configuration
        render json: {
          config: {
            base_url: Rails.configuration.payment.mangopay.base_url,
            client_id: Rails.configuration.payment.mangopay.client_id
          }
        }, status: 200
      end
    end
  end
end
