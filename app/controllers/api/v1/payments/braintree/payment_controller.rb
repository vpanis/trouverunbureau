module Api
  module V1
    module Payments
      module Braintree
        class PaymentController < ApiController
          include RepresentedHelper
          before_action :authenticate_user!, only: [:customer_nonce_token]

          # nonce token to pay
          def customer_nonce_token
            @payment = BraintreePayment.find_by_id(params[:payment_id])
            return render json: { token: token }, status: 400 unless @payment.present?
            token = @payment.payment_nonce_token if @payment.payment_nonce_expire.present? &&
              Time.new < @payment.payment_nonce_expire
            @payment.update_attributes(payment_nonce_token: nil, payment_nonce_expire: nil) unless
              token.present?
            render json: { token: token }, status: 200
          end
        end
      end
    end
  end
end
