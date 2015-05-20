class Organization < ActiveRecord::Base
  include OwnerActions
  # Only for creation purpose
  attr_accessor :user, :user_id

  devise :invitable

  # Relations
  has_many :organization_users
  has_many :users, through: :organization_users
  has_many :venues, as: :owner
  has_many :bookings, as: :owner
  has_one :braintree_payment_account, as: :buyer
  has_one :mangopay_payment_account, as: :buyer

  # Uploaders
  mount_uploader :logo, LogoUploader

  # Callbacks
  after_initialize :initialize_fields
  after_create :assign_user

  # Validations
  # Only for the creation stage, it needs a user
  validate :require_user, unless: :created_at

  validates :name, :email, :phone, presence: true

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

  def user_in_organization(user)
    users.exists?(user)
  end

  private

  def initialize_fields
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
    if user.present?
      User.find(user.id)
    elsif user_id.present?
      User.find(user_id)
    end
  rescue
    errors.add(:user, 'Invalid user/user_id value')
  end

  def assign_user
    if user.present?
      organization_users.create(user_id: user.id, role: OrganizationUser.roles[:owner])
    elsif user_id.present?
      organization_users.create(user_id: user_id, role: OrganizationUser.roles[:owner])
    end
  end
end
