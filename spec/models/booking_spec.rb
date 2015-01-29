require 'rails_helper'

RSpec.describe Booking, type: :model do
  subject { FactoryGirl.create(:booking) }

  # Relations
  it { should belong_to(:owner) }
  it { should belong_to(:space) }
  it { should have_many(:messages) }

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

  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  it 'should fail if the space don\'t have the booking type price' do
    space = FactoryGirl.create(:space, day_price: 10, month_price: nil)
    booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:month])
    expect(booking.valid?).to be(false)
    expect(booking.errors[:price_not_found_for_b_type]).to be_present
  end

end
