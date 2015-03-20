class MangopayPaymentAccountWorker
  include Sidekiq::Worker

  # The mangopay_payment_account.buyer.id it would be different from the user_id in the
  # case that the account it's for an Organization. Just for the moment. In the future
  # the Organization MUST have a Business account (Legal User in mangopay)
  def perform(user_id, mangopay_payment_account_id)
    init_log(user_id, mangopay_payment_account_id)
    @user = User.find_by_id(user_id)
    @mangopay_payment_account = MangopayPaymentAccount.find_by_id(mangopay_payment_account_id)
    return unless @user.present? && @mangopay_payment_account.present?

    account = create_user
    save_payment_account(account)
  rescue MangoPay::ResponseError => e
    save_account_error(e.errors)
  end

  private

  def init_log(user_id, mangopay_payment_account_id)
    str = "MangopayPaymentAccountWorker on user_id: #{user_id}, "
    str += "mangopay_payment_account_id: #{mangopay_payment_account_id}"
    Rails.logger.info(str)
  end

  def save_payment_account(account)
    @mangopay_payment_account.mangopay_user_id = account['Id']
    wallet = create_wallet(account['Id'])
    @mangopay_payment_account.wallet_id = wallet["Id"]
    @mangopay_payment_account.status = MangopayPaymentAccount.statuses[:accepted]
    @mangopay_payment_account.save
  end

  def save_account_error(e)
    @mangopay_payment_account.error_message = e.to_s
    @mangopay_payment_account.status = MangopayPaymentAccount.statuses[:rejected]
    @mangopay_payment_account.save
  end

  def create_user
    MangoPay::NaturalUser.create(
      firstName: @user.first_name,
      lastName: @user.last_name,
      birthday: Time.new.advance(years: -23).to_i, #fixed for testing
      nationality: 'GB', #fixed for testing
      countryOfResidence: 'GB', #fixed for testing
      email: @user.email)
  end

  def create_wallet(mangopay_user_id)
    MangoPay::Wallet.create(
      owners: [mangopay_user_id],
      currency: "EUR",
      description: "Buyer wallet")
  end
end
