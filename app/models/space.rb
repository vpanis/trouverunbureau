class Space < ActiveRecord::Base
  # Relations
  belongs_to :venue

  has_many :bookings
  has_many :photos, class_name: 'VenuePhoto'

  # Constants/Enums
  enum s_type: [:conference_room, :meeting_room, :office, :desk]

  # Validations
  validates :s_type, :name, :capacity, :quantity, :venue, presence: true

  validates :capacity, :quantity, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :hour_price, :day_price, :week_price, :month_price, numericality: {
    greater_than: 0
  }, allow_nil: true

  validate :at_least_one_price

  def can_update(space_params)
    capacity_param = (space_params[:capacity] || capacity).to_i
    quantity_param = (space_params[:quantity] || quantity).to_i
    !(capacity_param.nil? || capacity_param < capacity || quantity_param < quantity)
  end

  private

  def at_least_one_price
    return if hour_price.present? ||
      day_price.present? || week_price.present? || month_price.present?
    errors.add(:price, 'Needs at least one price')
  end

end
