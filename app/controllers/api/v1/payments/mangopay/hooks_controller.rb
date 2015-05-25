module Api
  module V1
    module Payments
      module Mangopay
        class HooksController < ApiController
          ### READ ###:
          # every worker is called because a condition race between the worker that creates
          # the model with this 'RessourceId' and this hook that tries to retrieve it.

          # GET /mangopay/payin_succeeded?RessourceId&EventType=PAYIN_NORMAL_SUCCEEDED&Date
          def payin_succeeded
            ::Payments::PayinSuccessForHookWorker.perform_async(
              params['RessourceId'], params['Date'].to_i, 0)
            render nothing: true, status: 200
          end

          # GET /mangopay/payin_failed?RessourceId&EventType=PAYIN_NORMAL_FAILED&Date
          def payin_failed
            ::Payments::Mangopay::FetchPayinErrorForHookWorker.perform_async(
              params['RessourceId'], params['Date'].to_i, 0)
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_succeeded?RessourceId&EventType=PAYOUT_REFUND_SUCCEEDED&Date
          def refund_succeeded
            ::Payments::PayoutSuccessForHookWorker.perform_async(
              params['RessourceId'], params['Date'].to_i, 0, true)
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_succeeded?RessourceId&EventType=PAYOUT_REFUND_FAILED&Date
          def refund_failed
            ::Payments::Mangopay::FetchPayoutErrorForHookWorker.perform_async(
              params['RessourceId'], params['Date'].to_i, 0, true)
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_succeeded?RessourceId&EventType=PAYOUT_NORMAL_SUCCEEDED&Date
          def payout_succeeded
            ::Payments::PayoutSuccessForHookWorker.perform_async(
              params['RessourceId'], params['Date'].to_i, 0, false)
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_failed?RessourceId&EventType=PAYOUT_NORMAL_FAILED&Date
          def payout_failed
            ::Payments::Mangopay::FetchPayoutErrorForHookWorker.perform_async(
              params['RessourceId'], params['Date'].to_i, 0, false)
            render nothing: true, status: 200
          end
        end
      end
    end
  end
end
