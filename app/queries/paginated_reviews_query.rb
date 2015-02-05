class PaginatedReviewsQuery < PaginatedQuery

  def venue_reviews(pagination_params, venue_id)
    @relation = select_reviews_for_venue(venue_id)
    paginate(pagination_params)
    @relation
  end

  def client_reviews(pagination_params, user_id)
    @relation = select_reviews_for_client(user_id)
    paginate(pagination_params)
    @relation
  end

  def select_reviews_for_venue(venue_id)
    ans = VenueReview.joins { booking.space } .where { booking.space.venue_id == my { venue_id } }
    ans.order { created_at.desc }.includes { booking.owner }
  end

  def select_reviews_for_client(user_id)
    ans = ClientReview.joins { booking } .where { booking.owner_type == User and booking.owner_id == my { user_id } }
    ans.order { created_at.desc }.includes { booking.space.venue }
  end
end
