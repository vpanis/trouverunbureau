class VenueDetailStepEdition < SimpleDelegator
  include ActiveModel::Validations

  validates :description, presence: true
  validate :each_profession_inclusion
  validate  :at_least_one_day_hour

  def at_least_one_day_hour
    errors.add(:day_hours, "you must select at least one") if day_hours.size == 0
  end

  def each_profession_inclusion
    each_inclusion(professions, :profession_list, Venue::PROFESSIONS, ' is not a valid profession')
  end

  def each_inclusion(attribute, error_list, enum_list, error_message)
    attribute = [] if attribute.nil?
    invalid_items = attribute - enum_list.map(&:to_s)
    invalid_items.each do |item|
      errors.add(error_list, item + error_message)
    end
  end

end
