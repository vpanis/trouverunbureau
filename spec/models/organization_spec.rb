require 'rails_helper'

RSpec.describe Organization, type: :model do
  subject { FactoryGirl.create(:organization) }

  # Relations
  it { should have_many(:organization_users) }
  it { should have_many(:users).through(:organization_users) }
  it { should have_many(:venues) }
  it { should have_many(:bookings) }
  it { should have_one(:braintree_payment_account) }
  it { should have_one(:mangopay_payment_account) }

  # Presence
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:phone) }

  # Callbacks
  context 'callbacks' do
    it { is_expected.to callback(:initialize_fields).after(:initialize) }
    it { is_expected.to callback(:assign_user).after(:create) }
  end

  # Numericality
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

  it 'should create a OrganizationUser' do
    user = FactoryGirl.create(:user)
    organization = FactoryGirl.create(:organization, user: user)
    expect(organization.users.count).to eq(1)
  end
end
