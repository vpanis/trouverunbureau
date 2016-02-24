require 'rails_helper'

RSpec.describe TimeZone, type: :model do
  # Relations
  it { should have_many(:venues) }

  # Presence
  it { should validate_presence_of(:zone_identifier) }
  it { should validate_presence_of(:seconds_utc_difference) }

  # Uniqueness
  it { should validate_uniqueness_of(:zone_identifier).case_insensitive }

  it do
    should validate_numericality_of(:seconds_utc_difference).only_integer
  end

  describe '#from_zone_to_utc' do
    let(:tz) { FactoryGirl.build(:time_zone) }

    it 'recieves a utc time and adds it the difference with this zone' do
      t = DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
      expect(tz.from_zone_to_utc(t)).to eq t
    end
  end
end
