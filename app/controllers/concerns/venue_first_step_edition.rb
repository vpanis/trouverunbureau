class VenueFirstStepEdition < SimpleDelegator
  # This validator is the one used just after the venue is created.
  # It will only validate part of the data

  include ActiveModel::Validations

  validates :town, :street, :postal_code, :email, :currency, :v_type, :owner, :name,
            :latitude, :longitude, :country_code, presence: true

  validates :latitude, numericality: {
    greater_than_or_equal_to: -90, less_than_or_equal_to: 90
  }, unless: :force_submit

  validates :longitude, numericality: {
    greater_than_or_equal_to: -180, less_than_or_equal_to: 180
  }, unless: :force_submit

  validates :email, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create
  }, unless: :force_submit
end
