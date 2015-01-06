require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryGirl.create(:user) }

  # Relations
  it { should have_many(:venues) }
  it { should have_many(:organizations) }
  it { should have_many(:organization_venues) }
  it { should have_many(:spaces) }
  it { should have_many(:bookings) }

  # Presence
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:email) }

  # Numericality
  it do
    should validate_numericality_of(:rating)
    .is_less_than_or_equal_to(5)
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:quantity_reviews)
    .only_integer
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:reviews_sum)
    .only_integer
    .is_greater_than_or_equal_to(0)
  end
end
