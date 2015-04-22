class VenueCollectionAccountsController < VenuesController
  before_action :authenticate_user!

  def collection_account_info
    @venue = Venue.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?
    return render nothing: true, status: 403 unless current_represented == @venue.owner

    if @venue.collection_account.present?
      @collection_account = @venue.collection_account
    else
      @collection_account = BraintreeCollectionAccount.new(force_submit: true,
                                                           expecting_braintree_response: false,
                                                           braintree_persisted: false)
    end
  end

  def edit_collection_account
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

  def create_collection_account_if_nil
    return if @venue.collection_account.present?
    @venue.collection_account =
      BraintreeCollectionAccount.new(force_submit: true, expecting_braintree_response: false,
                                     braintree_persisted: false)
    @venue.save
    @venue.collection_account.force_submit = false
  end

  def create_update_collection_account_in_braintree
    data = @venue.collection_account.braintree_merchant_account_json
    unless data.empty?
      @venue.collection_account.reload
      @venue.collection_account.update_attributes(expecting_braintree_response: true,
                                                  force_submit: true)
      BraintreeSubMerchantAccountWorker.perform_async(@venue.collection_account.id, data)
    end
    redirect_to collection_account_info_venue_path(@venue)
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
