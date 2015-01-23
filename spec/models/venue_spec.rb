require 'rails_helper'

RSpec.describe Venue, type: :model do
  subject { FactoryGirl.create(:venue) }

  # Relations
  it { should belong_to(:owner) }
  it { should have_many(:spaces) }
  it { should have_many(:day_hours) }
  it { should have_many(:photos) }

  # Presence
  it { should validate_presence_of(:town) }
  it { should validate_presence_of(:street) }
  it { should validate_presence_of(:postal_code) }
  it { should validate_presence_of(:country) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:latitude) }
  it { should validate_presence_of(:longitude) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:v_type) }
  it { should validate_presence_of(:vat_tax_rate) }
  it { should validate_presence_of(:owner) }

  it { should_not validate_presence_of(:floors) }
  it { should_not validate_presence_of(:rooms) }
  it { should_not validate_presence_of(:desks) }

  # Enums
  it { should define_enum_for(:v_types) }
  it { should define_enum_for(:space_units) }

  # Numericality
  it do
    should validate_numericality_of(:rating)
    .is_less_than_or_equal_to(5)
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:latitude)
    .is_less_than_or_equal_to(90)
    .is_greater_than_or_equal_to(-90)
  end

  it do
    should validate_numericality_of(:longitude)
    .is_less_than_or_equal_to(180)
    .is_greater_than_or_equal_to(-180)
  end

  it do
    should validate_numericality_of(:space)
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:vat_tax_rate)
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:floors)
    .only_integer.is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:rooms)
    .only_integer.is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:desks)
    .only_integer.is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:quantity_reviews)
    .only_integer.is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:reviews_sum)
    .only_integer.is_greater_than_or_equal_to(0)
  end

  it 'shouldn\'t accept invalid amenities' do
    venue = FactoryGirl.build(:venue, amenities: ['not_existing_amenity'])
    should venue.valid? be false
  end

  it 'shouldn\'t accept invalid primary professions' do
    venue = FactoryGirl.build(:venue, primary_professions: ['not_existing_amenity'])
    should venue.valid? be false
  end

  it 'shouldn\'t accept invalid secondary professions' do
    venue = FactoryGirl.build(:venue, secondary_professions: ['not_existing_amenity'])
    should venue.valid? be false
  end

  it 'shouldn\'t have the professions same profession in both arrays' do
    venue = FactoryGirl.create(:venue,
                               primary_professions: [Venue::PROFESSIONS[0].to_s],
                               secondary_professions: [Venue::PROFESSIONS[0].to_s])

    expect(venue.primary_professions & venue.secondary_professions).to contain_exactly
    expect(venue.primary_professions).to include(Venue::PROFESSIONS[0].to_s)
    expect(venue.secondary_professions).not_to include(Venue::PROFESSIONS[0].to_s)
  end
end
