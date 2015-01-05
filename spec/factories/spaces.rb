# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :space do
  	s_type :desk.to_s
  	name { Faker::Lorem.word }
  	capacity 1
  	quantity 4
  	description { Faker::Lorem.sentence }
  	
    venue { FactoryGirl.build(:venue) }
  end
end
