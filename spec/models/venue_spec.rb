require 'rails_helper'

RSpec.describe Venue, type: :model do
  subject { FactoryGirl.create(:venue) }

  # Relations
  it { should belong_to(:collection_account).dependent(:destroy) }
  it { should belong_to(:owner) }
  it { should belong_to(:time_zone) }
  it { should have_many(:bookings).through(:spaces) }
  it { should have_many(:day_hours).dependent(:destroy).class_name('VenueHour') }
  it { should have_many(:photos).dependent(:destroy).class_name('VenuePhoto') }
  it { should have_many(:spaces).dependent(:destroy) }
  it { should have_one(:referral_stat) }

  # Nested Attributes
  it { should accept_nested_attributes_for(:day_hours).allow_destroy(true) }

  # Callbacks
  context 'callbacks' do
    it { is_expected.to callback(:initialize_fields).after(:initialize) }
  end

  # Presence
  it { should validate_presence_of(:town) }
  it { should validate_presence_of(:street) }
  it { should validate_presence_of(:postal_code) }
  it { should validate_presence_of(:country_code) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:latitude) }
  it { should validate_presence_of(:longitude) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:v_type) }
  it { should validate_presence_of(:owner) }

  it { should_not validate_presence_of(:floors) }
  it { should_not validate_presence_of(:rooms) }
  it { should_not validate_presence_of(:desks) }

  # Enums
  it { should define_enum_for(:v_type).with([:coworking_space, :startup_office, :hotel, :corporate_office, :business_center,
                :design_studio, :loft, :apartment, :house, :cafe, :restaurant]) }
  it { should define_enum_for(:space_unit).with([:square_mts, :square_foots]) }
  it { should define_enum_for(:status).with([:creating, :active, :reported, :closed]) }

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

  it 'shouldn\'t accept invalid professions' do
    venue = FactoryGirl.build(:venue, professions: ['not_existing_amenity'])
    should venue.valid? be false
  end

  describe '#maximum_open_lapse' do
    it 'returns the max lapse of time for a day open in a venue' do
      expect(subject.maximum_open_lapse).to eq(12)
    end

    it 'returns nil for an Venue without opening days set' do
      subject.day_hours.clear
      expect(subject.maximum_open_lapse).to be_nil
    end
  end
end
