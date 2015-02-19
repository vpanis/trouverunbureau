class PaginatedReviewsQuery

  def venue_reviews(pagination_params, venue_id)
    select_reviews_for_venue(venue_id).paginate(pagination_params)
  end

  def client_reviews(pagination_params, client_id, entity)
    select_reviews_for_client(client_id, entity).paginate(pagination_params)
  end

  def select_reviews_for_venue(venue_id)
    VenueReview.joins { booking.space } .where { booking.space.venue_id == my { venue_id } }
      .order('created_at desc').includes { booking.owner }
  end

  def select_reviews_for_client(client_id, entity)
    ClientReview.joins { booking }
      .where { (booking.owner_type == my { entity }) & (booking.owner_id == my { client_id }) }
      .order('created_at desc').includes { booking.space.venue }
  end
end
