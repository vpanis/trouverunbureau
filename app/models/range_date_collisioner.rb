class RangeDateCollisioner
  include ActiveModel::Model

  attr_accessor :max_collition_permited, :errors, :first_date, :minute_granularity

  # if the ordered_and_clean flag is in true it will asume that every add_time_range
  # will have a from equal of bigger than the previous one, and, will delete the ranges
  # smallers that this new from
  attr_accessor :ordered_and_clean, :range_array

  # Validations
  validates :max_collition_permited, :first_date, presence: true

  validates :minute_granularity, :max_collition_permited, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  validates :minute_granularity, numericality: {
    only_integer: true,
    greater_than: 0
  }

  def initialize(attributes = {})
    attributes['ordered_and_clean'] ||= true
    attributes['minute_granularity'] ||= 60
    attributes['range_array'] = []
    super(attributes)
  end

  def add_time_range(from, to, quantity)
    return if from.nil? || to.nil? || from > to ||
              quantity <= 0 || quantity > max_collition_permited
    range_entry = new_range_entry(time_to_range_number(from), time_to_range_number(to), quantity)
    add_range_entry(range_entry)
  end

  def valid?
    errors.blank?
  end

  private

  def add_range_entry(range_entry)
    self.range_array.map! do |element|
      break if range_entry.nil?
      range_entry, element_to_return = try_to_collide_elements(range_entry, element)
      element_to_return
    end
    self.range_array = self.range_array.compact if ordered_and_clean
    self.range_array = self.range_array.flatten
    self.range_array.push(range_entry) if range_entry.present?
  end

  def try_to_collide_elements(range_entry, element)
    # entry bigger
    if range_smaller_than?(element[:range], range_entry[:range])
      [range_entry, element_to_return_if_smaller(element)]
    # entry smaller, only possible with ordered_and_clean = false
    elsif range_smaller_than?(range_entry[:range], element[:range])
      [nil, [range_entry, element]]
    else
      collide_elements(range_entry, element)
    end

  end

  def collide_elements(range_entry, element)
    response = [nil, []]
    mins_not_equal!(range_entry, element, response) unless
      range_entry[:range][:min] == element[:range][:min]
    aux_r = maxs_not_equal!(range_entry, element, response) unless
      range_entry[:range][:max] == element[:range][:max]
    response[1].push(validate_new_entry(range_entry[:range][:min],
                                        range_entry[:range][:max],
                                        range_entry[:quantity] + element[:quantity]))
    response[1].push(aux_r) unless aux_r.nil?
    response
  end

  def mins_not_equal!(range_entry, element, response)
    if range_entry[:range][:min] > element[:range][:min]
      aux = element_to_return_if_smaller(
        new_range_entry(element[:range][:min], range_entry[:range][:min] - 1, element[:quantity]))
      element[:range] = range_entry[:range][:min]..element[:range][:max]
    else
      aux = new_range_entry(range_entry[:range][:min], 
                            element[:range][:min] - 1, range_entry[:quantity])
      range_entry[:range] = element[:range][:min]..range_entry[:range][:max]
    end
    response[1].push(aux)
  end

  def maxs_not_equal!(range_entry, element, response)
    if range_entry[:range][:max] > element[:range][:max]
      response[0] = new_range_entry(element[:range][:max] + 1,
                                    range_entry[:range][:max],
                                    range_entry[:quantity])
      range_entry[:range] = range_entry[:range][:min]..element[:range][:max]
      nil
    else
      new_range_entry(range_entry[:range][:max] + 1, element[:range][:max], element[:quantity])
    end
  end

  def new_range_entry(min, max, quantity)
    { range: min..max, quantity: quantity }
  end

  def element_to_return_if_smaller(element)
    return nil if ordered_and_clean
    element
  end

  def range_smaller_than?(range1, range2)
    range1.max < range2.min
  end

  def validate_new_entry(entry)
    errors ||= []
    errors.push(from: range_number_to_time(entry[:range][:min]),
                to: range_number_to_time(entry[:range][:max]),
                quantity: entry[:quantity]) if entry[:quantity] <= max_collition_permited
    entry
  end

  def time_to_range_number(time)
    return 0 if time <= first_date

    ((time - first_date).round / 1.minute) / minute_granularity
  end

  def range_number_to_time(range_number)
    first_date.advance(minutes: range_number * minute_granularity)
  end
end
