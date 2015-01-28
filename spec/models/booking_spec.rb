require 'rails_helper'

RSpec.describe Booking, type: :model do
  subject { FactoryGirl.create(:booking) }

  # Relations
  it { should belong_to(:owner) }
  it { should belong_to(:space) }

  # Presence
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:space) }
  it { should validate_presence_of(:b_type) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:from) }
  it { should validate_presence_of(:to) }

  # Enums
  it { should define_enum_for(:b_types) }
  it { should define_enum_for(:states) }

  # Numericality
  it do
    should validate_numericality_of(:quantity)
    .only_integer.is_greater_than_or_equal_to(1)
  end

end
