module Api
  module V1
    module Payments
      module Mangopay
        class HooksController < ApiController

          # GET /mangopay/payin_succeeded?RessourceId&EventType=PAYIN_NORMAL_SUCCEEDED&Date
          def payin_succeeded
            mp = MangopayPayment.find_by_transaction_id(params['RessourceId'])
            return unless mp.present? && mp.notification_date_int.to_i <= params['Date'].to_i
            mp.update_attributes(transaction_status: 'PAYIN_SUCCEEDED',
                                 notification_date_int: params['Date'].to_i)
            BookingManager.change_booking_status(mp.user_paying, mp.booking, Booking.states[:paid])
            render nothing: true, status: 200
          end

          # GET /mangopay/payin_failed?RessourceId&EventType=PAYIN_NORMAL_FAILED&Date
          def payin_failed
            mp = MangopayPayment.find_by_transaction_id(param['RessourceId'])
            return unless mp.present? && mp.notification_date_int.to_i <= params['Date'].to_i
            BookingManager.change_booking_status(mp.user_paying, mp.booking,
                                                 Booking.states[:pending_payment])
            # This update is not performed in the worker because, if the same hook is
            # triggered before the worker starts, will trigger a duplicate worker.
            mp.update_attributes(notification_date_int: params['Date'].to_i,
                                 transaction_status: 'PAYIN_FAILED')
            ::Payments::Mangopay::FetchPayinErrorWorker.perform_async(mp.id)
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_succeeded?RessourceId&EventType=PAYOUT_REFUND_SUCCEEDED&Date
          def refund_succeeded
            mp = MangopayPayout.find_by(transaction_id: params['RessourceId'],
                                        p_type: MangopayPayout.p_types[:refund])
            return unless mp.present? && mp.notification_date_int.to_i <= params['Date'].to_i
            b = mp.mangopay_payment.booking
            BookingManager.change_booking_status(mp.user, b,
                                                 b.state_if_represented_cancels(mp.represented)) if
                b.state == 'refunding'
            mp.update_attributes(transaction_status: 'REFUND_SUCCEEDED',
                                 notification_date_int: params['Date'].to_i)
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_succeeded?RessourceId&EventType=PAYOUT_REFUND_FAILED&Date
          def refund_failed
            mp = MangopayPayout.find_by(transaction_id: params['RessourceId'],
                                        p_type: MangopayPayout.p_types[:refund])
            return unless mp.present? && mp.notification_date_int.to_i <= params['Date'].to_i
            BookingManager.change_booking_status(mp.user, mp.mangopay_payment.booking,
                                                 Booking.states[:error_refunding])
            # This update is not performed in the worker because, if the same hook is
            # triggered before the worker starts, will trigger a duplicate worker.
            mp.update_attributes(notification_date_int: params['Date'].to_i,
                                 transaction_status: 'TRANSACTION_FAILED')
            ::Payments::Mangopay::FetchPayoutErrorWorker.perform_async(mp.id)
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_succeeded?RessourceId&EventType=PAYOUT_NORMAL_SUCCEEDED&Date
          def payout_succeeded
            mp = MangopayPayout.find_by(transaction_id: params['RessourceId'],
                                        p_type: MangopayPayout.p_types[:payout_to_user])
            return unless mp.present? && mp.notification_date_int.to_i <= params['Date'].to_i
            mp.update_attributes(transaction_status: 'PAYOUT_SUCCEEDED',
                                 notification_date_int: params['Date'].to_i)
            BookingManager.change_booking_status(mp.user, mp.mangopay_payment.booking,
                                                 Booking.states[:denied]) if
              mp.mangopay_payment.booking == 'refunding'
            render nothing: true, status: 200
          end

          # GET /mangopay/payout_failed?RessourceId&EventType=PAYOUT_NORMAL_FAILED&Date
          def payout_failed
            mp = MangopayPayout.find_by(transaction_id: params['RessourceId'],
                                        p_type: MangopayPayout.p_types[:payout_to_user])
            return unless mp.present? && mp.notification_date_int.to_i <= params['Date'].to_i
            # This update is not performed in the worker because, if the same hook is
            # triggered before the worker starts, will trigger a duplicate worker.
            mp.update_attributes(notification_date_int: params['Date'].to_i,
                                 transaction_status: 'TRANSACTION_FAILED')
            ::Payments::Mangopay::FetchPayoutErrorWorker.perform_async(mp.id)
            render nothing: true, status: 200
          end
        end
      end
    end
  end
end
