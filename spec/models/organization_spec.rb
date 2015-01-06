require 'rails_helper'

RSpec.describe Organization, type: :model do
  subject { FactoryGirl.create(:organization) }

  # Relations
  it { should have_many(:organization_users) }
  it { should have_many(:users) }
  it { should have_many(:venues) }
  it { should have_many(:bookings) }

  # Presence
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:phone) }

  it 'should create a OrganizationUser' do
    user = FactoryGirl.create(:user)
    organization = FactoryGirl.create(:organization, user: user)
    expect(organization.users.count).to eq(1)
  end
end
