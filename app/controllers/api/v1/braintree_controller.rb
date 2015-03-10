module Api
  module V1
    class BraintreeController < ApplicationController
      include RepresentedHelper
      before_action :authenticate_user!, only: [:current_represented_customer_token]

      def verify_url
        render status: 200, json: Braintree::WebhookNotification.verify(params['bt_challenge'])
      end

      def notification
        webhook_notification = Braintree::WebhookNotification.parse(
          params['bt_signature'], params['bt_payload'])
        send(webhook_notification.kind, webhook_notification)
      end

      def current_represented_customer_token
        token = current_represented.payment_token
        current_represented.update_attributes(payment_token: nil)
        render json: { token: token }, status: 200
      end

      private

      def sub_merchant_account_approved(notification)
        bca = BraintreeCollectionAccount.find_by_merchant_account_id(
                notification.merchant_account.id)
        if bca.present?
          bca.update_attributes(status: notification.merchant_account.status, active: true)
        else
          log_account_id_error(notification.merchant_account.id)
        end
        render status: 200, nothing: true
      end

      def sub_merchant_account_declined(notification)
        bca = BraintreeCollectionAccount.find_by_merchant_account_id(
                notification.merchant_account.id)
        if bca.present?
          bca.update_attributes(status: notification.merchant_account.status, active: false,
                                error_message: notification.message)
        else
          log_account_id_error(notification.merchant_account.id)
        end
        render status: 200, nothing: true
      end

      def log_account_id_error(id)
        Rails.logger.error "Braintree Collection Account id: '#{id}' does not exists"
      end
    end
  end
end
