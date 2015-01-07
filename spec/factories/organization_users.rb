# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization_user do
    role OrganizationUser.roles[:owner]

    user { FactoryGirl.build(:user) }
    organization { FactoryGirl.build(:organization) }
  end
end
