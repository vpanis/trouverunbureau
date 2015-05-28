# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :space do
    s_type Space.s_types[:hot_desk]
    name { Faker::Lorem.word }
    capacity 1
    quantity 4
    description { Faker::Lorem.sentence }
    hour_price 20
    day_price 150
    hour_minimum_unity 1
    day_minimum_unity 1
    week_minimum_unity 1
    month_minimum_unity 1
    deposit 50
    active true

    venue { FactoryGirl.build(:venue) }
  end
end
