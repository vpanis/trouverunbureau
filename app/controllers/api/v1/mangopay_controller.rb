module Api
  module V1
    class MangopayController < ApiController
      include RepresentedHelper
      before_action :authenticate_user!

      # GET /mangopay/configuration
      def configuration
        render json: {
          config: {
            base_url: Rails.configuration.payment.mangopay.base_url,
            client_id: Rails.configuration.payment.mangopay.client_id
          }
        }, status: 200
      end

      # POST /mangopay/card_registration
      def card_registration
        return render nothing: true, status: 400 unless params[:currency].present?
        mcc = current_represented.mangopay_payment_account.mangopay_credit_cards
          .create!(status: MangopayCreditCard.statuses[:registering],
                   currency: params[:currency].upcase,
                   registration_expiration_date: Time.new.advance(hours: 6))
        MangopayCardRegistrationWorker.perform_async(mcc.id)
        render json: { mangopay_credit_card_id: mcc.id }, status: 200
      end

      # GET /mangopay/new_card_info?mangopay_credit_card_id
      def new_card_info
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

      # PUT /mangopay/start_payment
      def start_payment
        @booking = Booking.find_by_id(params[:id])
        return render nothing: true, status: 400 unless booking.present? &&
          !param[:card_id].blank? && payment_mangopay_verification
        return render nothing: true, status: 403 unless @booking.owner == current_represented
        @booking, custom_errors = BookingManager.change_booking_status(
                                    current_user, @booking, Booking.states[:payment_verification])
        return render nothing: true, status: 400 unless @booking.valid? && custom_errors.empty?
        payment = payment_mangopay(params[:card_id])
        render json: { mangopay_payment: { id: payment.id } }, status: 201
      end

      # GET /mangopay/payin_succeeded?RessourceId&EventType=PAYIN_NORMAL_SUCCEEDED&Date
      def payin_succeeded
        mp = MangopayPayment.find_by_transaction_id(params[:RessourceId])
        return unless mp.present? && mp.notification_date_int <= params[:Date]
        mp.update_attributes(transaction_status: 'SUCCEEDED', notification_date_int: params[:Date])
      end

      # GET /mangopay/payin_failed?RessourceId&EventType=PAYIN_NORMAL_FAILED&Date
      def payin_failed
        mp = MangopayPayment.find_by_transaction_id(params[:RessourceId])
        return unless mp.present? && mp.notification_date_int <= params[:Date]
        # This update is not performed in the worker because, if the same hook is
        # triggered before the worker starts, will trigger a duplicate worker.
        mp.update_attributes(notification_date_int: params[:Date])
        MangopayFetchTransactionWorker.perform_async(mp.id)
      end

      private

      def payment_mangopay_verification
        current_represented.mangopay_payment_account.present? &&
          current_represented.mangopay_payment_account.accepted?
      end

      def payment_mangopay(credit_card)
        unless @booking.payment.present?
          @booking.payment = MangopayPayment.new
          @booking.save
        end
        MangopayPaymentWorker.perform_async(@booking.id, credit_card,
                                            current_user.id, current_represented.id,
                                            current_represented.class.to_s)
        @booking.payment
      end

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
