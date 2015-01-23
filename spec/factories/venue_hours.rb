# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue_hour do
    weekday 1
    from 800
    to 2000

    venue { FactoryGirl.build(:venue) }
  end
end
