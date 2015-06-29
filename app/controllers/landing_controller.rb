class LandingController < ApplicationController
  inherit_resources
  include SelectOptionsHelper

  def index
    @space_types_options = space_types_index_options
    @featured_venues = Venue.distinct.joins(:spaces).where('spaces.active')
                            .where(status: Venue.accepted_statuses)
                            .order(reviews_sum: :desc).limit(8)
    @trending_cities = Space.joins(:venue).where(venue: { status: Venue.accepted_statuses })
                            .group(venues: :town).limit(8).order('count_town desc')
                            .count(:town).to_a
    @workspaces = workspaces_count
  end

  private

  def workspaces_count
    type_count = Space.active.group(:s_type).count
    results = []
    (0..5).each { |n| results[n] = type_count[n] }
    results
  end
end
