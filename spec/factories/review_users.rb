# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review_user do
    message { Faker::Lorem.sentence }
    stars { rand(5) + 1 }
    active true

    trait :with_new_user do
    	user { FactoryGirl.build(:user) }
    end

    trait :with_new_from_user do
    	from_user { FactoryGirl.build(:user) }
    end
  end
end
