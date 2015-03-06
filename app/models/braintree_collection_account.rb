class BraintreeCollectionAccount < ActiveRecord::Base
  # Relations
  has_one :venue

  after_create :generate_merchant_account_id

  @append_random = Rails.configuration.payment.braintree.append_random_to_accounts_ids

  private

  def generate_merchant_account_id
    return if merchant_account_id.present?
    update_attribute(merchant_account_id: "#{SecureRandom.hex(8) + '-' if @append_random}#{id}")
  end

end
