class ClientReview < ActiveRecord::Base
  # Relations
  belongs_to :client, polymorphic: true
  belongs_to :from_user, class_name: 'User'

  # Callbacks
  after_initialize :initialize_fields
  after_create :update_ratings, if: :active
  after_destroy :update_ratings, if: :active

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
    client.quantity_reviews = ClientReview.where(client_id: client.id, active: true).size
    client.reviews_sum = ClientReview.where(client_id: client.id, active: true).sum(:stars)
    if client.quantity_reviews != 0
      client.rating = client.reviews_sum / (client.quantity_reviews * 1.0)
    else
      client.rating = 0
    end
    client.save
  end
end
