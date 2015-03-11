class VenuesController < ModelController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper
  before_action :authenticate_user!, except: [:show]

  def edit
    @venue = Venue.find(params[:id])
    return unless can_edit?
    @countries_options = countries_options
    @v_types_options = venue_types_options
    @currency_options = currency_options
  end

  def new
    @venue = Venue.new
    @countries_options = countries_options
  end

  def create
    venue = Venue.create(new_venue_params)
    venue.update_attributes!(owner: current_represented, email: current_represented.email)
    redirect_to edit_venue_path(venue)
  end

  def update
    @venue = Venue.find(params[:id])
    return unless can_edit?
    @venue.update_attributes!(edit_venue_params)
    redirect_to details_venue_path(@venue)
  end

  def photos
    @venue = Venue.find(params[:id])
    return unless can_edit?
  end

  def spaces
    @venue = Venue.find(params[:id])
    return unless can_edit?
  end

  def show
    @venue = Venue.find(params[:id])
    @user = current_represented
    @photos = @venue.photos
    @selected_space = Space.find(params[:space_id]) if params[:space_id]
    # favorites of the user
    if current_user.present?
      @favorite_spaces_ids = current_user.favorite_spaces.pluck(:id)
    else
      @favorite_spaces_ids = []
    end
  end

  def index
    @venues = current_represented.venues
  end

  def collection_account_info
    @venue = Venue.find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present?

    unless @venue.collection_account.present?
      @venue.collection_account =
        BraintreeCollectionAccount.new(force_submit: true, expecting_braintree_response: false,
                                       braintree_persisted: false)
      @venue.save
    end
    @collection_account = @venue.collection_account
  end

  def edit_collection_account
    @venue = Venue.includes(:collection_account).find_by(id: params[:id])
    return render nothing: true, status: 404 unless @venue.present? &&
      @venue.collection_account.present?

    @venue.collection_account.assign_attributes(braintree_collection_params)
    return create_update_collection_account if @venue.collection_account.valid?

    render json: @venue.collection_account.errors, status: 400
  end

  private

  def can_edit?
    return true if VenueContext.new(@venue, current_represented).owner?
    render nothing: true, status: 403
    false
  end

  def create_update_collection_account
    data = @venue.collection_account.braintree_merchant_account_json
    unless data.empty?
      Resque.enqueue(BraintreeSubMerchantAccountJob, @venue.collection_account.id, data)
      @venue.collection_account.reload
      @venue.collection_account.update_attributes(expecting_braintree_response: true,
                                                  force_submit: true)
    end
    render nothing: true, status: 201
  end

  def object_params
    params.require(:venue).permit(:town, :street, :postal_code, :phone, :email, :website,
                                  :latitude, :longitude, :name, :description, :currency, :v_type,
                                  :space, :space_unit, :floors, :rooms, :desks, :vat_tax_rate,
                                  :amenities, :rating, :professions, :country,
                                  day_hours_attributes: [:id, :from, :to, :weekday, :_destroy])
  end

  def new_venue_params
    params.require(:venue).permit(:name, :country_id, :logo, :force_submit)
  end

  def edit_venue_params
    params.require(:venue).permit(:name, :street, :country_id, :town, :postal_code, :email, :phone,
                                  :v_type, :currency, :latitude, :longitude, :logo,
                                  :force_submit_upd)
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
