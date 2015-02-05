class PaginatedReviewsQuery < PaginatedQuery

  def initialize(venue_id)
    @venue_id = venue_id
  end

  def reviews(pagination_params)
    @relation = select_reviews_for_venue
    paginate(pagination_params)
    @relation
  end

  def select_reviews_for_venue
    ans = VenueReview.joins { booking.space } .where { booking.space.venue_id == my { @venue_id } }
    ans.order { created_at.desc }.includes { booking.owner }
  end
end
