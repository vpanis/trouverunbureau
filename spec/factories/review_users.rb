# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review_user do
    message { Faker::Lorem.sentence }
    stars { rand(5) + 1 }
    active true

    user { FactoryGirl.build(:user) }
    from_user { FactoryGirl.build(:user) }
  end
end
