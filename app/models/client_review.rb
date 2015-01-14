class ClientReview < ActiveRecord::Base
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
    result = calculate_count_sum_client_review_stars
    booking.owner.quantity_reviews = result['count']
    booking.owner.reviews_sum = result['stars_sum'] || 0
    if booking.owner.quantity_reviews != 0
      booking.owner.rating = booking.owner.reviews_sum / (booking.owner.quantity_reviews * 1.0)
    else
      booking.owner.rating = 0
    end
    booking.owner.save
  end

  def calculate_count_sum_client_review_stars
    sql = "SELECT COUNT(*), SUM(client_reviews.stars) as stars_sum
           FROM client_reviews
           INNER JOIN bookings
             ON bookings.id = client_reviews.booking_id
           WHERE bookings.owner_id=#{booking.owner_id}
             AND bookings.owner_type='#{booking.owner_type}'
             AND client_reviews.active"
    ActiveRecord::Base.connection.select_all(sql).first
  end
end
