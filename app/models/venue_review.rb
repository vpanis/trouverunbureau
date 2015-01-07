class VenueReview < ActiveRecord::Base
  # Relations
  belongs_to :venue
  belongs_to :from_user, class_name: 'User'

  # Callbacks
  after_initialize :initialize_fields
  after_create :update_ratings, if: :active
  after_destroy :update_ratings, if: :active

  # Validations
  validates :venue, :from_user, :stars, presence: true
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
    venue.quantity_reviews = VenueReview.where(venue_id: venue.id, active: true).size
    venue.reviews_sum = VenueReview.where(venue_id: venue.id, active: true).sum(:stars)
    if venue.quantity_reviews != 0
      venue.rating = venue.reviews_sum / (venue.quantity_reviews * 1.0)
    else
      venue.rating = 0
    end
    venue.save
  end
end
