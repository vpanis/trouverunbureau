# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :users_favorite do
    since { Faker::Time.between(2.days.ago, Time.now) }

    trait :with_new_user do
    	user { FactoryGirl.build(:user) }
    end

    trait :with_new_space do
    	space { FactoryGirl.build(:space) }
    end
  end
end
