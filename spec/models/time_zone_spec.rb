require 'rails_helper'

RSpec.describe TimeZone, type: :model do
  # Relations
  it { should have_many(:venues) }

  # Presence
  it { should validate_presence_of(:zone_identifier) }
  it { should validate_presence_of(:minute_utc_difference) }

  it do
    should validate_numericality_of(:minute_utc_difference).only_integer
  end
end
