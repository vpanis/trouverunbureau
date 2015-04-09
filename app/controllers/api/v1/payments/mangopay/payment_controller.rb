module Api
  module V1
    module Payments
      module Mangopay
        class PaymentController < ApiController
          include RepresentedHelper
          before_action :authenticate_user!

          # PUT /mangopay/start_payment
          def start_payment
            @booking = Booking.includes(:payment, space: [:venue])
                         .where(id: params[:booking_id], owner: current_represented).first
            return render nothing: true, status: 400 unless valid_params?
            return render nothing: true, status: 403 unless @booking.owner == current_represented
            @booking, custom_errors = BookingManager.change_booking_status(
                                    current_user, @booking, Booking.states[:payment_verification])
            return render nothing: true, status: 400 unless @booking.valid? && custom_errors.empty?
            payment = payment_mangopay(params[:card_id])
            render json: { mangopay_payment: { id: payment.id } }, status: 201
          end

          # GET /mangopay/payment_info?payment_id
          def payment_info
            @payment = MangopayPayment.find_by_id(params[:payment_id])
            return render nothing: true, status: 400 unless @payment.present?
            return render nothing: true, status: 403 unless
              @payment.booking.owner == current_represented
            return render json: nil, status: 200 if @payment.expecting_response?
            return render json: { error: @payment.error_message }, status: 412 if @payment.failed?
            render json: { redirect_url: @payment.redirect_url }, status: 200
          end

          private

          def payment_mangopay_verification?
            current_represented.mangopay_payment_account.present? &&
              current_represented.mangopay_payment_account.accepted?
          end

          def payment_mangopay(credit_card_id)
            unless @booking.payment.present?
              # needs a transaction_status to be valid, and because the reference is in the
              # booking, because it's a polimorfic reference, needs to be persisted in it
              @booking.payment = MangopayPayment.new(transaction_status: 'EXPECTING_RESPONSE')
              @booking.save
            end

            @booking.payment.update_attributes(transaction_status: 'EXPECTING_RESPONSE',
                                               user_paying: current_user)
            Payments::Mangopay::PaymentWorker.perform_async(@booking.id, credit_card_id,
                                                            current_user.id, root_path)
            @booking.payment
          end

          def valid_params?
            @booking.present? && @booking.pending_payment? && payment_mangopay_verification? &&
              MangopayCreditCard.joins(:mangopay_payment_account).where(id: params[:card_id].to_i)
                .where { mangopay_payment_account.buyer == my { @booking.owner } }.first.present?
            # credit card belongs to the booking_owner
          end
        end
      end
    end
  end
end
