class BraintreePaymentAccount < ActiveRecord::Base

  class << self
    def generate_customer_id(owner)
      str = "#{owner.class.to_s.first}-#{owner.id}"
      str = SecureRandom.hex(8) + '-' + str if
        Rails.configuration.payment.braintree.append_random_to_accounts_ids
      str
    end
  end

end
