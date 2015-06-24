class LandingController < ApplicationController
  inherit_resources
  include RepresentedHelper
  include SelectOptionsHelper

  def index
    @space_types_options = space_types_index_options
    # TODO: que tengan al menos una foto y esten publicados.
    #       where sean de un venue valido y tengan foto
    @featured_venues = Venue.distinct.joins(:spaces).where('spaces.active')
                            .where(status: Venue.accepted_statuses)
                            .order(reviews_sum: :desc).limit(8)
    @trending_cities = Space.joins(:venue).where(venue: { status: Venue.accepted_statuses })
                            .group(venues: :town).limit(8).order('count_town desc')
                            .count(:town).to_a
    @workspaces = workspaces_count
  end

  def about_us
    show_static_page('about_us')
  end

  def our_terms
    show_static_page('our_terms')
  end

  def how_it_works
    show_static_page('how_it_works')
  end

  def faq
    show_static_page('faq')
  end

  def contact
    show_static_page('contact')
  end

  def terms_of_service
    show_static_page('terms_of_service')
  end

  def privacy_policy
    show_static_page('privacy_policy')
  end

  private

  def workspaces_count
    type_count = Space.active.group(:s_type).count
    results = []
    (0..5).each { |n| results[n] = type_count[n] }
    results
  end

  def show_static_page(name)
    @title = t("home.footer.#{name}")
    @content = t("static_page_content.#{name}")
    render layout: 'static_pages', text: ''
  end

end
