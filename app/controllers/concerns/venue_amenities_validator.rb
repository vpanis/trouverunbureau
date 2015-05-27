class VenueAmenitiesValidator < SimpleDelegator
  include ActiveModel::Validations

  validate :each_amenity_inclusion

  def each_amenity_inclusion
    each_inclusion(amenities, :amenity_list, Venue::AMENITY_TYPES, ' is not a valid amenity')
  end

  def each_inclusion(attribute, error_list, enum_list, error_message)
    attribute = [] if attribute.nil?
    invalid_items = attribute - enum_list.map(&:to_s)
    invalid_items.each do |item|
      errors.add(error_list, item + error_message)
    end
  end
end
