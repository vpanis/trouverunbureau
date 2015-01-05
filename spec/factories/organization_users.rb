# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization_users do
    role :owner.to_s

    user { FactoryGirl.build(:user) }
    venue { FactoryGirl.build(:organization) }
  end
end
