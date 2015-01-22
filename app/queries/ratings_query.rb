class RatingsQuery
  class << self
    def calculate_count_and_review_sum_for_client(client)
      sql = "SELECT COUNT(*), SUM(client_reviews.stars) as stars_sum
             FROM client_reviews
             INNER JOIN bookings
               ON bookings.id = client_reviews.booking_id
             WHERE bookings.owner_id=#{client.id}
               AND bookings.owner_type='#{client.class}'
               AND client_reviews.active"
      ActiveRecord::Base.connection.select_all(sql).first
    end

    def calculate_count_and_review_sum_for_venue(venue)
      sql = "SELECT COUNT(*), SUM(venue_reviews.stars) as stars_sum
             FROM venue_reviews
             INNER JOIN bookings
               ON bookings.id = venue_reviews.booking_id
             INNER JOIN spaces
               ON spaces.id = bookings.space_id
             WHERE spaces.venue_id=#{venue.id}
               AND venue_reviews.active"
      ActiveRecord::Base.connection.select_all(sql).first
    end
  end
end
