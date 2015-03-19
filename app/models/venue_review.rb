class VenueReview < ActiveRecord::Base
  # what the client says about his stay at this venue

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
    venue = booking.space.venue
    result = RatingsQuery.calculate_count_and_review_sum_for_venue(venue)
    venue.quantity_reviews = result['count']
    venue.reviews_sum = result['stars_sum'] || 0
    if venue.quantity_reviews != 0
      venue.rating = venue.reviews_sum / (venue.quantity_reviews * 1.0)
    else
      venue.rating = 0
    end
    venue.save
  end
end
