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

  # Favorite spaces
  has_many :favorite_spaces, through: :users_favorites, source: :space

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :first_name, :password, presence: true

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
    on: :create
  }, uniqueness: {
    case_sensitive: false
  }, allow_nil: true

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
      user_found = where('email = :email OR provider = :provider AND uid = :uid',
                         email: auth.info.email, provider: auth.provider, uid: auth.uid).first
      if user_found.nil?
        create_provider_user(auth)
      else
        add_provider_if_necessary(user_found, auth)
      end
    end

    private

    def create_provider_user(auth)
      create(provider: auth.provider, uid: auth.id, email: auth.info.email,
             password: Devise.friendly_token[0, 20], first_name: auth.info.first_name,
             last_name: auth.info.last_name)
    end

    def add_provider_if_necessary(user, auth)
      return user unless user.provider != auth.provider || user.uid != auth.uid

      # add the provider and uid if necessary
      user.provider = auth.provider
      user.uid = auth.uid
      user.save
      user
    end
  end

  def name
    name = first_name
    name = name + ' ' + last_name if last_name.present?
    name
  end

  def email_required?
    provider.nil?
  end

  private

  def initialize_fields
    self.quantity_reviews ||= 0
    self.reviews_sum ||= 0
    self.rating ||= 0
  end
end
