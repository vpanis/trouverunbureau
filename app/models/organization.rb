class Organization < ActiveRecord::Base
  # Only for creation purpose
  attr_accessor :user, :user_id

  # Relations
  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :venues, as: :owner
  has_many :bookings, as: :owner

  # Callbacks
  before_validation :default_rating_values, unless: :created_at
  after_create :assign_user

  # Validations
  # Only for the creation stage, it needs a user
  validate :require_user, unless: :created_at

  validates :name, :email, :phone, :quantity_reviews, :reviews_sum, :rating,
            presence: true

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
    on: :create
  }

  validates :quantity_reviews, :reviews_sum, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :rating, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }

  private

  def default_rating_values
    self.quantity_reviews ||= 0
    self.reviews_sum ||= 0
    self.rating ||= 0
  end

  def require_user
    if user.nil? && user_id.nil?
      errors.add(:user, 'Needs to have a user/user_id value')
    else
      user_exists?
    end
  end

  def user_exists?
    if !user.nil?
      User.find(user.id)
    elsif !user_id.nil?
      User.find(user_id)
    end
  rescue
    errors.add(:user, 'Invalid user/user_id value')
  end

  def assign_user
    if !user.nil?
      organization_users.create(user_id: user.id, role: 'owner')
    elsif !user_id.nil?
      organization_users.create(user_id: user_id, role: 'owner')
    end
  end
end
