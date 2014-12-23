# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :users_favorite do
    since { Faker::Time.between(2.days.ago, Time.now) }

   	user { FactoryGirl.build(:user) }
    space { FactoryGirl.build(:space) }
  end
end
