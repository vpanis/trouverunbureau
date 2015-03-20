module Api
  module V1
    class MangopayController < ApiController
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

      def card_registration
        return render nothing: true, status: 400 unless params[:currency].present?
        mcc = current_represented.mangopay_payment_account.mangopay_credit_cards
          .create!(status: MangopayCreditCard.statuses[:registering],
                   currency: params[:currency].upcase)
        MangopayCardRegistrationWorker.perform_async(mcc.id)
        render json: { mangopay_credit_card_id: mcc.id }, status: 200
      end

      def new_card_info
        mcc = MangopayCreditCard.find_by_id(params[:mangopay_credit_card_id])
        return render nothing: true, status: 400 unless mcc.present?
        return render nothing: true, status: 403 unless
          mcc.mangopay_payment_account.buyer == current_represented
        render_mangopay_credit_card_cases(mcc)
      end

      private

      def render_mangopay_credit_card_cases(mcc)
        return render json: nil, status: 200 if mcc.needs_validation?
        return render json: { error: mcc.error_message }, status: 500 if mcc.failed?
        render json: {
          registration_id: mcc.registration_id,
          registration_access_key: mcc.registration_access_key,
          card_registration_url: mcc.card_registration_url,
          pre_registration_data: mcc.pre_registration_data
        }, status: 200
      end
    end
  end
end
