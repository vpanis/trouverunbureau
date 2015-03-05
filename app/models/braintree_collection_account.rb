class BraintreeCollectionAccount < ActiveRecord::Base
  # Relations
  has_one :venue

  before_create :generate_merchant_account_id

  @append_random = Rails.configuration.payment.braintree.append_random_to_accounts_ids

  private

  def generate_merchant_account_id
    str = "#{@represented.class}-#{@represented.id}"
    str = SecureRandom.hex + '-' + str if @append_random
    self.merchant_account_id = str
  end

end
