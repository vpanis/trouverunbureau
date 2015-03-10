class BraintreeTokenGenerationJob
  @queue = :braintree_token_generation

  class << self
    def perform(represented_id, represented_type)
      init_log(represented_id, represented_type)
      @represented = represented_type.constantize.find_by_id(represented_id)
      return unless @represented.present? # impossible, but...

      braintree_token
    end

    private

    def init_log(represented_id, represented_type)
      str = "BraintreeTokenGenerationJob on represented_id: #{represented_id}, "
      str += "represented_type: #{represented_type}"
      Rails.logger.info(str)
    end

    def braintree_token
      if @represented.payment_customer_id.present?
        token = Braintree::ClientToken.generate(customer_id: @represented.payment_customer_id)
      else
        token = Braintree::ClientToken.generate
      end
      @represented.update_attributes(payment_token: token)
    end
  end
end
