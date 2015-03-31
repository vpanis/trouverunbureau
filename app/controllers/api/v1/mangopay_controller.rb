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

      def save_credit_card
        mcc = MangopayCreditCard.find_by_id(params[:mangopay_credit_card][:id])
        return render nothing: true, status: 400 unless mcc.present?
        return render nothing: true, status: 403 unless
          mcc.mangopay_payment_account.buyer == current_represented
        params[:mangopay_credit_card][:status] = MangopayCreditCard.statuses[:created]
        return render nothing: true, status: 201 if mcc.update_attributes(credit_card_params)
        render json: { error: mcc.errors }, status: 400
      end

      private

      def credit_card_params
        params.require(:mangopay_credit_card).permit(:credit_card_id, :last_4, :expiration,
                                                     :card_type, :status)
      end

      def render_mangopay_credit_card_cases(mcc)
        return render json: nil, status: 200 if mcc.registering?
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
