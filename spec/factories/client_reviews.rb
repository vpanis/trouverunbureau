# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :client_review do
    message { Faker::Lorem.sentence }
    stars { rand(5) + 1 }
    active true

    booking { FactoryGirl.build(:booking) }
  end
end
