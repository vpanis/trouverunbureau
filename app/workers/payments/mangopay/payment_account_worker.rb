module Payments
  module Mangopay
    class PaymentAccountWorker
      include Sidekiq::Worker

      # The mangopay_payment_account.buyer.id it would be different from the user_id in the
      # case that the account it's for an Organization. Just for the moment. In the future
      # the Organization MUST have a Business/Organization account (Legal User in mangopay)
      def perform(user_id, mangopay_payment_account_id)
        init_log(user_id, mangopay_payment_account_id)
        @user = User.find_by_id(user_id)
        @mangopay_payment_account = MangopayPaymentAccount.find_by_id(mangopay_payment_account_id)
        return unless @user.present? && @mangopay_payment_account.present?

        account = create_user
        save_payment_account(account)
      rescue MangoPay::ResponseError => e
        save_account_error(e.message)
      end

      private

      def init_log(user_id, mangopay_payment_account_id)
        str = "Payments::Mangopay::PaymentAccountWorker on user_id: #{user_id}, "
        str += "mangopay_payment_account_id: #{mangopay_payment_account_id}"
        Rails.logger.info(str)
      end

      def save_payment_account(account)
        wallet = create_wallet(account['Id'])
        @mangopay_payment_account.update_attributes(wallet_id: wallet['Id'],
          mangopay_user_id: account['Id'], status: MangopayPaymentAccount.statuses[:accepted])
      end

      def save_account_error(e)
        @mangopay_payment_account.update_attributes(
          error_message: e.to_s, status: MangopayPaymentAccount.statuses[:rejected])
      end

      def create_user
        MangoPay::NaturalUser.create(
          firstName: @user.first_name,
          lastName: @user.last_name,
          birthday: Time.new.advance(years: -23).to_i, # fixed for testing
          nationality: 'GB', # fixed for testing
          countryOfResidence: 'GB', # fixed for testing
          email: @user.email)
      end

      def create_wallet(mangopay_user_id)
        MangoPay::Wallet.create(
          owners: [mangopay_user_id],
          currency: 'EUR',
          description: 'Buyer wallet')
      end
    end
  end
end
