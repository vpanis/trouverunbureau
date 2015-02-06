class RangeEntry
  include ActiveModel::Model

  attr_accessor :range, :element

  validates :range, :element, presence: true

  def initialize(attributes = {})
    attributes[:range] = attributes[:min]..attributes[:max] if attributes[:range].nil? &&
                                                               attributes[:max].present? &&
                                                               attributes[:min].present?
    attributes.delete(:min)
    attributes.delete(:max)
    super(attributes)
  end

  delegate :min, :max, to: :range

  def range_smaller_than?(range_entry)
    max < range_entry.min
  end
end
