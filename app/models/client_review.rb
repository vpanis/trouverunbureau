class ClientReview < ActiveRecord::Base
  # Relations
  belongs_to :client, polymorphic: true
  belongs_to :from_user, class_name: 'User'

  # Callbacks
  before_validation :default_active, unless: :created_at
  after_create :increase_ratings, if: :active
  after_destroy :decrease_ratings, if: :active

  # Validations
  validates :client, :from_user, :stars, presence: true
  validates :stars, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5
  }

  def deactivate!
    self.active = false
    save
    decrease_ratings
  end

  def activate!
    self.active = true
    save
    increase_ratings
  end

  private

  # starts active
  def default_active
    self.active ||= true
  end

  def increase_ratings
    client.quantity_reviews = client.quantity_reviews + 1
    client.reviews_sum = client.reviews_sum + stars
    client.rating = client.reviews_sum / (client.quantity_reviews * 1.0)
    client.save
  end

  def decrease_ratings
    client.quantity_reviews = client.quantity_reviews - 1
    client.reviews_sum = client.reviews_sum - stars
    if client.quantity_reviews != 0
      client.rating = client.reviews_sum / (client.quantity_reviews * 1.0)
    else
      client.rating = 0
    end
    client.save
  end
end
