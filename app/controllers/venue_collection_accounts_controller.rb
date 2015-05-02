class VenueCollectionAccountsController < VenuesController
  before_action :authenticate_user!

  def collection_account_info
    @venue = Venue.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?
    return render nothing: true, status: 403 unless current_represented == @venue.owner

    select_collection_method
    set_collection_account
  end

  def edit_collection_account
    binding.pry
    @venue = Venue.includes(:collection_account).find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?
    return render nothing: true, status: 403 unless current_represented == @venue.owner

    # it should pass first through collection_account_info, but just in case (and testing purpose)
    create_collection_account_if_nil

    @venue.collection_account.assign_attributes(braintree_collection_params)
    return create_update_collection_account_in_braintree if @venue.collection_account.valid?

    render json: @venue.collection_account.errors, status: 400
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
                                                        mangopay_persisted: false)
  end

  def create_collection_account_if_nil
    select_collection_method
    return if @venue.collection_account.present?
    set_collection_account
    @venue.collection_account = @collection_account
    @venue.save
    @venue.collection_account.force_submit = false
  end

  def create_update_collection_account_in_braintree
    data = @venue.collection_account.braintree_merchant_account_json
    unless data.empty?
      @venue.collection_account.reload
      @venue.collection_account.update_attributes(expecting_braintree_response: true,
                                                  force_submit: true)
      Payments::Braintree::SubMerchantAccountWorker.perform_async(@venue.collection_account.id,
                                                                  data)
    end
    @collection_account = @venue.collection_account
    render :collection_account_info, status: 201
  end

  def braintree_collection_params
    params.require(:braintree_collection_account)
      .permit(:first_name, :last_name, :email, :date_of_birth, :individual_street_address,
              :individual_locality, :individual_region, :individual_postal_code, :phone,
              :ssn, :legal_name, :dba_name, :tax_id, :business_street_address,
              :business_locality, :business_region, :business_postal_code, :descriptor,
              :account_number, :routing_number)
  end
end
