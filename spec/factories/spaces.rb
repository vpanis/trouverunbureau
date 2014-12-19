# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :space do
  	s_type :desk
  	name { Faker::Lorem.word }
  	capacity 1
  	quantity 4
  	description { Faker::Lorem.sentence }
  	trait :with_new_venue do
  		venue { FactoryGirl.build(:venue) }
  	end
  end
end
