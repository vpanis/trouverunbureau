require 'rails_helper'

RSpec.describe OrganizationUser, type: :model do
  subject { FactoryGirl.create(:organization_user) }

  # Relations
  it { should belong_to(:user) }
  it { should belong_to(:organization) }

  # Presence
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:organization) }
  it { should validate_presence_of(:role) }
end
