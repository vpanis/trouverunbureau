module Api
  module V1
    module Payments
      module Mangopay
        class HooksController < ApiController

          # GET /mangopay/payin_succeeded?RessourceId&EventType=PAYIN_NORMAL_SUCCEEDED&Date
          def payin_succeeded
            mp = MangopayPayment.find_by_transaction_id(params[:RessourceId])
            return unless mp.present? && mp.notification_date_int <= params[:Date]
            mp.update_attributes(transaction_status: 'PAYIN_SUCCEEDED',
                                 notification_date_int: params[:Date])
            BookingManager.change_booking_status(User.find(mp.user_paying_id), @booking,
                                                 Booking.states[:paid])
          end

          # GET /mangopay/payin_failed?RessourceId&EventType=PAYIN_NORMAL_FAILED&Date
          def payin_failed
            mp = MangopayPayment.find_by_transaction_id(params[:RessourceId])
            return unless mp.present? && mp.notification_date_int <= params[:Date]
            # This update is not performed in the worker because, if the same hook is
            # triggered before the worker starts, will trigger a duplicate worker.
            mp.update_attributes(notification_date_int: params[:Date])
            ::Payments::Mangopay::FetchPayinErrorWorker.perform_async(mp.id)
          end

          # GET /mangopay/payout_succeeded?RessourceId&EventType=PAYOUT_NORMAL_SUCCEEDED&Date
          def payout_succeeded
            mp = MangopayPayment.find_by_transaction_id(params[:RessourceId])
            return unless mp.present? && mp.notification_date_int <= params[:Date]
            mp.update_attributes(transaction_status: 'PAYOUT_SUCCEEDED',
                                 notification_date_int: params[:Date])
          end

          # GET /mangopay/payout_failed?RessourceId&EventType=PAYOUT_NORMAL_FAILED&Date
          def payout_failed
            mp = MangopayPayment.find_by_payout_id(params[:RessourceId])
            return unless mp.present? && mp.notification_date_int <= params[:Date]
            # This update is not performed in the worker because, if the same hook is
            # triggered before the worker starts, will trigger a duplicate worker.
            mp.update_attributes(notification_date_int: params[:Date])
            ::Payments::Mangopay::FetchPayoutErrorWorker.perform_async(mp.id)
          end
        end
      end
    end
  end
end
