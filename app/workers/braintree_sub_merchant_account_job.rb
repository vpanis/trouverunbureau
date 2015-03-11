class BraintreeSubMerchantAccountJob
  @queue = :braintree_sub_merchant_account
  @master_merchant_account_id = Rails.configuration.payment.braintree.merchant_account

  class << self
    def perform(collection_account_id, data)
      init_log(collection_account_id)
      @collection_account = BraintreeCollectionAccount.find_by_id(collection_account_id)
      return unless @collection_account.present? # impossible, but...

      create_or_update_merchant(data)
    end

    private

    def init_log(collection_account_id)
      str = "BraintreeSubMerchantAccountJob on collection_account_id: #{collection_account_id}"
      Rails.logger.info(str)
    end

    def create_or_update_merchant(data)
      if @collection_account.braintree_persisted
        merchant_wrapper = Braintree::MerchantAccount.create(creation_data(data))
      else
        merchant_wrapper = Braintree::MerchantAccount.update(
          @collection_account.merchant_account_id, data)
      end
    end

    def creation_data(data)
      data[:tos_accepted] = true
      data[:master_merchant_account_id] = @master_merchant_account_id
      data[:id] = @collection_account.merchant_account_id
      data
    end
  end
end
