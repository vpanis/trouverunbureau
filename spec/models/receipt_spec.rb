require 'rails_helper'

RSpec.describe Receipt, type: :model do
  subject { FactoryGirl.create(:receipt) }

  it { should validate_uniqueness_of(:booking_id) }
end
