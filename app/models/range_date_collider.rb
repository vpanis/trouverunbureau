class RangeDateCollider
  include ActiveModel::Model

  attr_accessor :max_collition_permited, :errors, :first_date, :minute_granularity

  # if the ordered_and_clean flag is in true it will asume that every add_time_range
  # will have a from equal of bigger than the previous one, and, will delete the ranges
  # smallers that this new from
  attr_accessor :ordered_and_clean, :range_array

  # Validations
  validates :max_collition_permited, :first_date, presence: true

  validates :minute_granularity, :max_collition_permited, numericality: {
    only_integer: true, greater_than_or_equal_to: 0 }

  validates :minute_granularity, numericality: {
    only_integer: true, greater_than: 0 }

  def initialize(attributes = {})
    attributes[:ordered_and_clean] ||= true
    attributes[:minute_granularity] ||= 60
    attributes[:range_array] = []
    attributes[:errors] = []
    super(attributes)
  end

  def add_time_range(from, to, quantity)
    return add_error(from, to, quantity, :invalid_entry) if from.nil? || to.nil? ||
                                                            from > to || quantity <= 0
    return add_error(from, to, quantity, :entry_exceed_max) if quantity > max_collition_permited
    range_entry = RangeEntry.new(min: time_to_range_number(from), max: time_to_range_number(to),
                                 element: quantity)
    add_range_entry(range_entry)
  end

  def valid?
    errors.blank?
  end

  private

  def add_range_entry(range_entry)
    range_array.map! do |element|
      break if range_entry.nil?
      range_entry, element_to_return = try_to_collide_elements(range_entry, element)
      element_to_return
    end
    self.range_array = range_array.flatten
    self.range_array = range_array.compact if ordered_and_clean
    range_array.push(range_entry) if range_entry.present?
  end

  def try_to_collide_elements(range_entry, old_range_entry)
    # entry bigger
    if old_range_entry.range_smaller_than?(range_entry)
      [range_entry, range_entry_to_return_if_smaller(old_range_entry)]
    # entry smaller, only possible with ordered_and_clean = false
    elsif range_entry.range_smaller_than?(old_range_entry)
      [nil, [range_entry, old_range_entry]]
    else
      collide_elements(range_entry, old_range_entry)
    end
  end

  def collide_elements(range_entry, old_range_entry)
    response = [nil, []]
    mins_not_equal!(range_entry, old_range_entry, response) unless
      range_entry.min == old_range_entry.min
    last_range = maxs_not_equal!(range_entry, old_range_entry, response) unless
      range_entry.max == old_range_entry.max
    middle_range = RangeEntry.new(min: range_entry.min, max: range_entry.max,
                                  element: range_entry.element + old_range_entry.element)
    response[1].push(validate_new_entry(middle_range))
    response[1].push(last_range) unless last_range.nil?
    response
  end

  def mins_not_equal!(range_entry, old_range_entry, response)
    if range_entry.min > old_range_entry.min
      aux = range_entry_to_return_if_smaller(RangeEntry.new(min: old_range_entry.min,
              max: range_entry.min - 1, element: old_range_entry.element))
      old_range_entry.range = range_entry.min..old_range_entry.max
    else
      aux = RangeEntry.new(min: range_entry.min, max: old_range_entry.min - 1,
                           element: range_entry.element)
      range_entry.range = old_range_entry.min..range_entry.max
    end
    response[1].push(aux)
  end

  def maxs_not_equal!(range_entry, old_range_entry, response)
    if range_entry.max > old_range_entry.max
      response[0] = RangeEntry.new(min: old_range_entry.max + 1, max: range_entry.max,
                                   element: range_entry.element)
      range_entry.range = range_entry.min..old_range_entry.max
      nil
    else
      RangeEntry.new(min: range_entry.max + 1, max: old_range_entry.max,
                     element: old_range_entry.element)
    end
  end

  def range_entry_to_return_if_smaller(range_entry)
    return nil if ordered_and_clean
    range_entry
  end

  def validate_new_entry(entry)
    add_error(range_number_to_time(entry.min), range_number_to_time(entry.max), entry.element,
              :collition_max_reached) unless entry.element <= max_collition_permited
    entry
  end

  def add_error(from, to, quantity, type)
    errors.push(from: from, to: to, quantity: quantity, type: type)
  end

  def time_to_range_number(time)
    return 0 if time <= first_date

    (((time - first_date) * 1.0 / 1.minute) / minute_granularity).floor
  end

  def range_number_to_time(range_number)
    first_date.advance(minutes: range_number * minute_granularity)
  end
end
