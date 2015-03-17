class BraintreeTokenGenerationWorker
  include Sidekiq::Worker

  def perform(represented_id, represented_type, payment_id)
    init_log(represented_id, represented_type, payment_id)
    @represented = represented_type.constantize.find_by_id(represented_id)
    @payment = BraintreePayment.find_by_id(payment_id)
    return unless @represented.present? && @payment.present? # impossible, but...
    braintree_token
  end

  private

  def init_log(represented_id, represented_type, payment_id)
    str = "BraintreeTokenGenerationWorker on represented_id: #{represented_id}, "
    str += "represented_type: #{represented_type}, payment_id: #{payment_id}"
    Rails.logger.info(str)
  end

  def braintree_token
    if @represented.braintree_payment_account.present?
      token = Braintree::ClientToken.generate(
                customer_id: @represented.braintree_payment_account.braintree_customer_id)
    else
      token = Braintree::ClientToken.generate
    end
    @payment.update_attributes(payment_nonce_token: token,
                               payment_nonce_expire: Time.new.advance(hours: 12))
  end
end
