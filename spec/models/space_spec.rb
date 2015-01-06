require 'rails_helper'

RSpec.describe Space, type: :model do
  subject { FactoryGirl.create(:space) }

  # Relations
  it { should belong_to(:venue) }
  it { should have_many(:bookings) }
  it { should have_one(:photo) }

  # Presence
  it { should validate_presence_of(:s_type) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:capacity) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:venue) }

  # Inclusion
  it { should validate_inclusion_of(:s_type).in_array(Space::TYPES.map(&:to_s)) }

  # Numericality
  it do
    should validate_numericality_of(:capacity)
    only_integer.is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:quantity)
    only_integer.is_greater_than_or_equal_to(0)
  end

end
