class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         omniauth_providers: [:facebook]
  # Relations
  has_many :venues, as: :owner
  # Organizations that the user have
  has_many :organization_users

  has_many :organizations, through: :organization_users
  # All the venues of the different organizations that the user belongs
  has_many :organization_venues, through: :organizations, source: :venues

  has_many :bookings, as: :owner

  has_many :users_favorites

  # Favorited spaces
  has_many :spaces, through: :users_favorites

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :first_name, :email, :password, presence: true

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
    on: :create
  }, uniqueness: {
    case_sensitive: false
  }

  validates :quantity_reviews, :reviews_sum, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :rating, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }

  class << self

    def from_omniauth(auth)

      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
      end

    end
  end

  def name
    name = first_name
    name = name + ' ' + last_name if last_name.present?
    name
  end

  private

  def initialize_fields
    self.quantity_reviews ||= 0
    self.reviews_sum ||= 0
    self.rating ||= 0
  end
end
