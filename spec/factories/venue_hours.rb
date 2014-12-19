# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue_hour do
    weekday 1
    from Time.now.advance(hours: -4)
    to Time.now.advance(hours: 4)

    trait :with_new_venue do
    	venue { FactoryGirl.build(:venue) }
    end
  end
end
