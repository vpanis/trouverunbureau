class VenueCollectionAccountsController < VenuesController
  before_action :authenticate_user!

  def collection_account_info
    @venue = Venue.find(params[:id])
    return render_forbidden unless current_represented == @venue.owner

    select_collection_method
    set_collection_account
  end

  def edit_collection_account
    @venue = Venue.includes(:collection_account).find(params[:id])
    byebug
    return render_forbidden unless current_represented == @venue.owner

    # it should pass first through collection_account_info, but just in case (and testing purpose)
    create_collection_account_if_nil

    @venue.collection_account.assign_attributes(collection_params)
    return create_update_collection_account if @venue.collection_account.valid?

    @collection_account = @venue.collection_account
    render :collection_account_info
  end

  private

  def select_collection_method
    if @venue.country_code == 'US'
      @collection_method = 'braintree'
    else
      @collection_method = 'mangopay'
    end
  end

  def set_collection_account
    if @venue.collection_account.present?
      @collection_account = @venue.collection_account
    else
      send("set_#{@collection_method}_collection_account")
    end
  end

  def set_braintree_collection_account
    @collection_account = BraintreeCollectionAccount.new(force_submit: true,
                                                         expecting_braintree_response: false,
                                                         braintree_persisted: false)
  end

  def set_mangopay_collection_account
    @collection_account = MangopayCollectionAccount.new(basic_info_only: true,
                                                        expecting_mangopay_response: false,
                                                        mangopay_persisted: false,
                                                        legal_person_type: 'PERSON',
                                                        bank_type: 'IBAN')
  end

  def create_collection_account_if_nil
    select_collection_method
    return if @venue.collection_account.present?
    set_collection_account
    @venue.collection_account = @collection_account
    @venue.save
    # manually resets the non-persisted field
    collection_account_force_submit(false)
  end

  def collection_account_force_submit(flag)
    return @venue.collection_account.force_submit = flag if @collection_method == 'braintree'
    @venue.collection_account.basic_info_only = flag
  end

  def create_update_collection_account
    send("create_update_collection_account_in_#{@collection_method}")
    @collection_account = @venue.collection_account
    redirect_to collection_account_info_venue_path(@venue)
  end

  def create_update_collection_account_in_braintree
    data = @venue.collection_account.braintree_merchant_account_json
    return if data.empty?
    @venue.collection_account.reload
    @venue.collection_account.update_attributes(expecting_braintree_response: true,
                                                force_submit: true)
    Payments::Braintree::SubMerchantAccountWorker.perform_async(@venue.collection_account.id,
                                                                data)
  end

  def create_update_collection_account_in_mangopay
    data = @venue.collection_account.json_data_for_mangopay
    return if data.empty?
    @venue.collection_account.reload
    @venue.collection_account.update_attributes(expecting_mangopay_response: true,
                                                basic_info_only: true)
    Payments::Mangopay::CollectionAccountWorker.perform_async(@venue.collection_account.id,
                                                              data)
  end

  def collection_params
    send("#{@collection_method}_collection_params")
  end

  def braintree_collection_params
    params.require(:braintree_collection_account)
      .permit(:first_name, :last_name, :email, :date_of_birth, :individual_street_address,
              :individual_locality, :individual_region, :individual_postal_code, :phone,
              :ssn, :legal_name, :dba_name, :tax_id, :business_street_address,
              :business_locality, :business_region, :business_postal_code, :descriptor,
              :account_number, :routing_number)
  end

  def mangopay_collection_params
    params.require(:mangopay_collection_account)
      .permit(:first_name, :last_name, :email, :date_of_birth, :address,
              :business_name, :business_email, :nationality, :country_of_residence, :bank_type,
              :iban, :bic, :sort_code, :bank_name, :bank_country, :institution_number,
              :account_number, :branch_code)
  end
end
