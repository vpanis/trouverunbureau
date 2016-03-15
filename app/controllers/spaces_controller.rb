class SpacesController < ApplicationController
  inherit_resources
  include SelectOptionsHelper
  before_action :authenticate_user!, except: [:index, :search_mobile]

  def new
    @venue = Venue.find(params[:id])
    return render_forbidden unless VenueContext.new(@venue, current_represented).owner?
    @space = Space.new(venue: @venue)
    @space_types_options = space_types_options
    @previous_page = session[:previous_url]
  end

  def create
    remove_blank_price_params
    space = Space.create!(space_params)
    redirect_to edit_space_path(space, previous_page: params[:previous_page])
  end

  def edit
    @space = Space.find(params[:id])
    return render_forbidden unless SpaceContext.new(@space, current_represented).owner?
    @space_types_options = space_types_options
    @previous_page = params[:previous_page] || session[:previous_url] || edit_space_path(@space)
  end

  def update
    remove_blank_price_params
    @space = Space.find(params[:id])
    context = SpaceContext.new(@space, current_represented)
    @previous_page = params[:previous_page] || edit_space_path(@space)
    return render_forbidden unless context.owner?
    return redirect_to @previous_page if context.update_space(space_params)
    redirect_to edit_space_path(@space)
  end

  def wishlist
    @current_user = current_user
  end

  def destroy
    space = Space.find(params[:id])
    venue = space.venue
    return render_forbidden unless SpaceContext.new(space, current_represented).owner?
    space.destroy!
    redirect_to spaces_venue_path(venue)
  end

  def index
    if params[:s_type].blank?
      set_meta_tags title: t('meta.spaces.index.title'),
                    description: t('meta.spaces.index.description')
    else
      set_meta_tags title: t("meta.spaces.space_#{params[:s_type]}.title"),
                    description: t("meta.spaces.space_#{params[:s_type]}.description")
    end

    @professions = profession_options
    @workspaces = space_types_checkbox_options
  end

  def search_mobile
    set_meta_tags title: t('meta.spaces.search_mobile.title'),
                  description: t('meta.spaces.search_mobile.description')
    @space_types_options = space_types_index_options
  end

  private

  def remove_blank_price_params
    return if params[:space].blank?
    params[:space].delete(:hour_price) if params[:space][:hour_price].blank?
    params[:space].delete(:day_price) if params[:space][:day_price].blank?
    params[:space].delete(:week_price) if params[:space][:week_price].blank?
    params[:space].delete(:month_price) if params[:space][:month_price].blank?
    params[:space].delete(:month_to_month_price) if params[:space][:month_to_month_price].blank?
  end

  def space_params
    params.require(:space).permit(:s_type, :name, :capacity, :quantity, :description, :deposit,
                                  :hour_price, :day_price, :week_price, :month_price, :month_to_month_price,
                                  :hour_minimum_unity, :day_minimum_unity, :month_minimum_unity, :month_to_month_minimum_unity,
                                  :venue_id)
  end
end
