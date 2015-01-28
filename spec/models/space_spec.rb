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

  # Enums
  it { should define_enum_for(:s_types) }

  # Numericality
  it do
    should validate_numericality_of(:capacity)
    .only_integer.is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:quantity)
    .only_integer.is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:hour_price)
    .is_greater_than(0).allow_nil
  end

  it do
    should validate_numericality_of(:day_price)
    .is_greater_than(0).allow_nil
  end

  it do
    should validate_numericality_of(:week_price)
    .is_greater_than(0).allow_nil
  end

  it do
    should validate_numericality_of(:month_price)
    .is_greater_than(0).allow_nil
  end

  it 'should have at least one price' do
    space = FactoryGirl.build(:space,
                              hour_price: nil,
                              day_price: nil,
                              week_price: nil,
                              month_price: nil)
    should space.valid? be false
  end

  it 'should add a price error if every price is nil' do
    space = FactoryGirl.build(:space,
                              hour_price: nil,
                              day_price: nil,
                              week_price: nil,
                              month_price: nil)
    space.valid?
    expect(space.errors[:price]).to be_present
  end
end
