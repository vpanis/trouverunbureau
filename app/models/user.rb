class User < ActiveRecord::Base
  include OwnerActions
  include SettingsModule
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable,
         :async, omniauth_providers: [:facebook]
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

  has_one :braintree_payment_account, as: :buyer
  has_one :mangopay_payment_account, as: :buyer

  # Uploaders
  mount_uploader :avatar, LogoUploader

  # Enums
  LANGUAGES = [:en, :fr, :de, :es, :pt]
  GENDERS = [:f, :m]
  SUPPORTED_NATIONALITIES = Country.all.map { |c| c[1] }

  # Callbacks
  after_initialize :initialize_fields

  # Validations
  validates :first_name, :last_name, :date_of_birth, :nationality, :country_of_residence,
            presence: true
  validates :password, presence: true, unless: :created_at

  validates :email, :emergency_email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }, allow_nil: true

  validates :email, uniqueness: { case_sensitive: false }

  validates :quantity_reviews, :reviews_sum, numericality: {
    only_integer: true, greater_than_or_equal_to: 0 }

  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }

  validates :profession, inclusion: { in: Venue::PROFESSIONS.map(&:to_s), allow_nil: true }
  validates :gender, inclusion: { in: GENDERS.map(&:to_s), allow_nil: true, allow_blank: true }
  validates :language, inclusion: { in: LANGUAGES.map(&:to_s), allow_nil: true }
  validates :nationality, :country_of_residence, inclusion: { in: SUPPORTED_NATIONALITIES }
  validate :each_languages_spoken_inclusion

  class << self

    def from_omniauth(auth)
      user_found = where('email = :email OR (provider = :provider AND uid = :uid)',
                         email: auth.info.email, provider: auth.provider, uid: auth.uid).first
      return create_provider_user(auth) if user_found.nil?
      add_provider_if_necessary(user_found, auth)
    end

    private

    def create_provider_user(auth)
      unless Rails.env.production?
        puts '*' * 50
        puts auth.to_yaml
        puts '*' * 50
      end
      date = auth.extra.raw_info.birthday.present? ? Date.strptime(auth.extra.raw_info.birthday, '%m/%d/%Y') : nil
      new(provider: auth.provider, uid: auth.uid, first_name: auth.info.first_name,
          email: auth.info.email, password: Devise.friendly_token[0, 20],
          last_name: auth.info.last_name,
          date_of_birth: date,
          location: auth.info.location,
          remote_avatar_url: auth.info.image.gsub('http://', 'https://'))
    end

    def add_provider_if_necessary(user, auth)
      return user unless user.provider != auth.provider || user.uid != auth.uid
      # add the provider and uid if necessary
      user.update_attributes(provider: auth.provider, uid: auth.uid)
      user
    end
  end

  def name
    first_name unless last_name.present?
    "#{first_name} #{last_name}"
  end

  def email_required?
    provider.nil?
  end

  def user_can_write_in_name_of(owner)
    if owner.class == User
      owner == self
    elsif owner.class == Organization
      owner.user_in_organization(self)
    else
      false
    end
  end

  def renew_authentication_token
    user.update_attributes(authentication_token: Devise.friendly_token)
  end

  def receives_person_message?
    settings_person_message?(settings)
  end

  def receives_account_changes?
    settings_account_changes?(settings)
  end

  def receives_accepted_inquiry?
    settings_accepted_inquiry?(settings)
  end

  def receives_incoming_inquiry?
    settings_incoming_inquiry?(settings)
  end

  private

  def initialize_fields
    self.quantity_reviews ||= 0
    self.reviews_sum ||= 0
    self.rating ||= 0
    self.settings = default_settings if settings.empty?
  end

  def each_languages_spoken_inclusion
    invalid_items = languages_spoken - LanguageList::COMMON_LANGUAGES.map(&:iso_639_1)
    invalid_items.each do |item|
      errors.add(:language_list, item + ' is not a valid language')
    end
  end

end
