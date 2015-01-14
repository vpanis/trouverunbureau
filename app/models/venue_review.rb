class VenueReview < ActiveRecord::Base
  # Relations
  belongs_to :booking

  # Callbacks
  after_initialize :initialize_fields
  after_create :update_ratings, if: :active
  after_destroy :update_ratings, if: :active

  # Validations
  validates :stars, :booking, presence: true
  validates :stars, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }

  def deactivate!
    self.active = false
    save
    update_ratings
  end

  def activate!
    self.active = true
    save
    update_ratings
  end

  private

  # starts active
  def initialize_fields
    self.active ||= true
  end

  def update_ratings
    result = calculate_count_sum_venue_review_stars
    venue = booking.space.venue
    venue.quantity_reviews = result['count']
    venue.reviews_sum = result['stars_sum'] || 0
    if venue.quantity_reviews != 0
      venue.rating = venue.reviews_sum / (venue.quantity_reviews * 1.0)
    else
      venue.rating = 0
    end
    venue.save
  end

  def calculate_count_sum_venue_review_stars
    sql = "SELECT COUNT(*), SUM(venue_reviews.stars) as stars_sum
           FROM venue_reviews
           INNER JOIN bookings
             ON bookings.id = venue_reviews.booking_id
           INNER JOIN spaces
             ON spaces.id = bookings.space_id
           WHERE spaces.venue_id=#{booking.space.venue_id}
             AND venue_reviews.active"
    ActiveRecord::Base.connection.select_all(sql).first
  end
end
