require 'rails_helper'

RSpec.describe Space, type: :model do
  subject { FactoryGirl.create(:space) }

  # Relations
  it { should belong_to(:venue) }
  it { should have_many(:bookings) }
  it { should have_many(:photos).class_name('VenuePhoto') }

  # Presence
  it { should validate_presence_of(:s_type) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:capacity) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:venue) }
  it { should validate_presence_of(:deposit) }

  # Callbacks
  context 'callbacks' do
    it { is_expected.to callback(:initialize_fields).after(:initialize) }
  end

  # Enums
  it {
    should define_enum_for(:s_types)
    .with([:conference_room, :meeting_room, :private_office, :fixed_desk,
          :hot_desk, :communal_space, :home_office])
  }

  # Numericality
  # every property used with `acts_as_decimal` is failing
  # it { should validate_numericality_of(:deposit).is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:capacity).only_integer.is_greater_than_or_equal_to(0) }
  it { should validate_numericality_of(:quantity).only_integer.is_greater_than_or_equal_to(0) }

  it { should validate_numericality_of(:hour_minimum_unity).only_integer.is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:day_minimum_unity).only_integer.is_greater_than_or_equal_to(1) }
  it { should validate_numericality_of(:week_minimum_unity).only_integer.is_greater_than_or_equal_to(1) }

  it { should validate_numericality_of(:month_minimum_unity).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(4) }
  it { should validate_numericality_of(:month_to_month_minimum_unity).only_integer.is_greater_than_or_equal_to(1).is_less_than_or_equal_to(4) }

  describe '#month_to_month_as_of' do
    let(:examples) { { nil => 0, 0 => 0, 1 => 30, 3 => 90, 4 => 120 } }
    it 'does something 1' do
      examples.each_pair do |k, v|
        space = FactoryGirl.build(:space, month_to_month_minimum_unity: k)
        expect(space.month_to_month_as_of).to eq(v)
      end
    end
  end

  context 'validates at_least_one_price' do
    it 'should have at least one price' do
      space = FactoryGirl.build(:space,
                                hour_price: nil,
                                day_price: nil,
                                week_price: nil,
                                month_price: nil)
      expect(space.valid?).to be_falsey
      expect(space.errors[:price]).to be_present
    end

    it 'should not add a price error if at least one price is set' do
      space = FactoryGirl.build(:space,
                                hour_price: 100,
                                day_price: nil,
                                week_price: nil,
                                month_price: nil)
      expect(space.valid?).to be_truthy
      expect(space.errors).to be_empty
    end
  end
end
