# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review_venue do
    message { Faker::Lorem.sentence }
    stars { rand(5) + 1 }
    active true

    venue { FactoryGirl.build(:venue) }
    from_user { FactoryGirl.build(:user) }
  end
end
