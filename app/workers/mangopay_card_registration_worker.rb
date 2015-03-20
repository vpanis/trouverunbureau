class MangopayCardRegistrationWorker
  include Sidekiq::Worker

  def perform(mangopay_credit_card_id)
    init_log(mangopay_credit_card_id)
    @mangopay_credit_card = MangopayCreditCard.find_by_id(mangopay_credit_card_id)
    return unless @mangopay_credit_card.present?

    card_registration = create_card_registration
    return save_credit_card_error(card_registration['ResultMessage']) if
      card_registration['Status'] == 'FAILED'
    save_credit_card(card_registration)
  rescue MangoPay::ResponseError => e
    save_credit_card_error(e.errors)
  end

  private

  def init_log(mangopay_credit_card_id)
    str = "MangopayCardRegistrationWorker on mangopay_credit_card_id: #{mangopay_credit_card_id}"
    Rails.logger.info(str)
  end

  def save_credit_card(card_registration)
    @mangopay_credit_card.update_attributes(
      registration_id: card_registration['Id'],
      registration_access_key: card_registration['AccessKey'],
      pre_registration_data: card_registration['PreregistrationData'],
      card_type: card_registration['CardType'],
      card_registration_url: card_registration['CardRegistrationURL'],
      status: MangopayCreditCard.statuses[:needs_validation])
  end

  def save_credit_card_error(e)
    @mangopay_credit_card.update_attributes(error_message: e.to_s,
                                            status: MangopayCreditCard.statuses[:failed])
  end

  def create_card_registration
    MangoPay::CardRegistration.create(
      userId: @mangopay_credit_card.mangopay_payment_account.mangopay_user_id,
      currency: @mangopay_credit_card.currency)
  end
end
