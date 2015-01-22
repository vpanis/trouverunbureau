# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :space do
    s_type Space.s_types[:desk]
    name { Faker::Lorem.word }
    capacity 1
    quantity 4
    description { Faker::Lorem.sentence }
    hour_price 20
    day_price 150

    venue { FactoryGirl.build(:venue) }
  end
end
