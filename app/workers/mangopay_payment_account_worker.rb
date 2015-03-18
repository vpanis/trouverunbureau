class MangopayPaymentAccountWorker
  include Sidekiq::Worker

  def perform(user_id)
    init_log(user_id)
    @user = User.includes(:mangopay_payment_account).find_by_id(user_id)
    return unless @user.present?

    account = create_user
    save_payment_account(account)
  rescue MangoPay::ResponseError => e
    save_account_error(e.errors)
  end

  private

  def init_log(user_id)
    str = "MangopayPaymentAccountWorker on user_id: #{user_id}"
    Rails.logger.info(str)
  end

  def save_payment_account(account)
    @user.mangopay_payment_account.mangopay_user_id = account['Id']
    @user.mangopay_payment_account.status = MangopayPaymentAccount.statuses[:accepted]
    @user.mangopay_payment_account.save
  end

  def save_account_error(e)
    @user.mangopay_payment_account.error_message = e.to_s
    @user.mangopay_payment_account.status = MangopayPaymentAccount.statuses[:rejected]
    @user.mangopay_payment_account.save
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
end
