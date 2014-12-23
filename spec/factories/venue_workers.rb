# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue_worker do
    role :owner

    user { FactoryGirl.build(:user) }
    venue { FactoryGirl.build(:venue) }
  end
end
