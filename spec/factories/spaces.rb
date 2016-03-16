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
    month_price 1500
    month_to_month_price 1200
    hour_minimum_unity 1
    day_minimum_unity 1
    week_minimum_unity 1
    month_minimum_unity 1
    month_to_month_minimum_unity 3
    deposit 0 #TODO remove
    hour_deposit 2
    day_deposit 15
    month_deposit 150
    month_to_month_deposit 120
    active true

    venue { FactoryGirl.build(:venue) }
  end
end
