class BraintreeSubMerchantAccountWorker
  include Sidekiq::Worker

  def perform(collection_account_id, data)
    init_log(collection_account_id)
    @collection_account = BraintreeCollectionAccount.find_by_id(collection_account_id)
    return unless @collection_account.present? && !data.empty? # impossible, but...

    create_or_update_merchant(data)
  end

  private

  def init_log(collection_account_id)
    str = "BraintreeSubMerchantAccountWorker on collection_account_id: #{collection_account_id}"
    Rails.logger.info(str)
  end

  def create_or_update_merchant(data)
    if !@collection_account.braintree_persisted
      merchant_wrapper = Braintree::MerchantAccount.create(creation_data(data))
    else
      merchant_wrapper = Braintree::MerchantAccount.update(
        @collection_account.merchant_account_id, data)
    end
    process_response(merchant_wrapper)
  end

  def process_response(merchant_wrapper)
    if merchant_wrapper.success?
      update_merchant_data(merchant_wrapper)
    else
      @collection_account.update_attributes(error_message: merchant_wrapper.message,
                                            force_submit: true, status: 'error',
                                            expecting_braintree_response: false)
    end
  end

  def creation_data(data)
    data[:tos_accepted] = true
    data[:master_merchant_account_id] = master_merchant_account_id
    data[:id] = @collection_account.merchant_account_id
    data
  end

  def master_merchant_account_id
    Rails.configuration.payment.braintree.merchant_account_id
  end

  def update_merchant_data(merchant_wrapper)
    technical_data = { status: merchant_wrapper.merchant_account.status,
                       braintree_persisted: true, expecting_braintree_response: false }
    if !@collection_account.braintree_persisted
      merchant_account = Braintree::MerchantAccount.find(@collection_account.merchant_account_id)
    else
      merchant_account = merchant_wrapper.merchant_account
    end

    @collection_account.update_attributes(update_merchant_data_attributes(merchant_account,
                                                                          technical_data))
  end

  def add_address_to_json(type, address, json)
    address.keys.each do |key|
      json[type + '_' + key] = address[key]
    end
  end

  def update_merchant_data_attributes(merchant_account, extra_data)
    json = individual_details_json(merchant_account)
      .merge(business_details_json(merchant_account))
      .merge(funding_details_json(merchant_account))
    json = json.merge(extra_data) unless extra_data.empty?
    json
  end

  def individual_details_json(merchant_account)
    json = merchant_account.individual_details.as_json
    json.delete('address_details')
    add_address_to_json('individual', json.delete('address'), json)
    json
  end

  def business_details_json(merchant_account)
    json = merchant_account.business_details.as_json
    json.delete('address_details')
    add_address_to_json('business', json.delete('address'), json)
    json
  end

  def funding_details_json(merchant_account)
    json = merchant_account.funding_details.as_json
    json.delete('destination')
    json.delete('email')
    json.delete('mobile_phone')
    json
  end
end
