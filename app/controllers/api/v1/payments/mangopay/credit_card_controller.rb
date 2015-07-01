module Api
  module V1
    module Payments
      module Mangopay
        class CreditCardController < ApiController
          before_action :authenticate_user!

          # POST /mangopay/card_registration
          def card_registration
            return render json: { error: 'user has no payment account' }, status: 412 unless
              current_represented.mangopay_payment_account.present?
            return render nothing: true, status: 400 unless params[:currency].present?
            mcc = current_represented.mangopay_payment_account.mangopay_credit_cards
              .create(status: MangopayCreditCard.statuses[:registering],
                      currency: params[:currency].upcase,
                      registration_expiration_date: Time.current.advance(hours: 6))
            return render json: { errors: mcc.errors }, status: 400 unless mcc.valid?
            ::Payments::Mangopay::CardRegistrationWorker.perform_async(mcc.id)
            render json: { mangopay_credit_card_id: mcc.id }, status: 200
          end

          # GET /mangopay/new_card_info?mangopay_credit_card_id
          def new_card_info
            return render json: { error: 'user has no payment account' }, status: 412 unless
              current_represented.mangopay_payment_account.present?
            mcc = MangopayCreditCard.find_by_id(params[:mangopay_credit_card_id])
            return render nothing: true, status: 400 unless mcc.present?
            return render nothing: true, status: 403 unless
              mcc.mangopay_payment_account.buyer == current_represented
            render_mangopay_credit_card_cases(mcc)
          end

          # PUT /mangopay/save_credit_card
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
            return render nothing: true, status: 202 if mcc.registering?
            return render json: { error: mcc.error_message }, status: 412 if mcc.failed?
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
  end
end
