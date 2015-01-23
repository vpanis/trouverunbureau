require 'rails_helper'

RSpec.describe VenueHour, type: :model do
  subject { FactoryGirl.create(:venue_hour) }

  # Relations
  it { should belong_to(:venue) }

  # Presence
  it { should validate_presence_of(:venue) }
  it { should validate_presence_of(:from) }
  it { should validate_presence_of(:to) }
  it { should validate_presence_of(:weekday) }

  # Numericality
  it do
    should validate_numericality_of(:weekday)
    .only_integer
    .is_less_than(7)
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:from)
    .only_integer
    .is_less_than(2400)
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:to)
    .only_integer
    .is_less_than(2400)
    .is_greater_than_or_equal_to(0)
  end

  it 'should accept that from/to ends with 00 or 30' do
    vh1 = FactoryGirl.build(:venue_hour, from: 200, to: 100)
    expect(vh1.valid?).to be(true)
    vh2 = FactoryGirl.build(:venue_hour, from: 230, to: 130)
    expect(vh2.valid?).to be(true)
  end

  it 'shouldn\'t accept that from/to ends with something different that 00 or 30' do
    vh1 = FactoryGirl.build(:venue_hour, from: 201, to: 100)
    expect(vh1.valid?).to be(false)
    expect(vh1.errors[:from]).to be_present
    vh2 = FactoryGirl.build(:venue_hour, from: 200, to: 120)
    expect(vh2.valid?).to be(false)
    expect(vh2.errors[:to]).to be_present
  end
end
