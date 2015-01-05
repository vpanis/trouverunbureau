# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :organization do
		user { FactoryGirl.create(:user) }
		name { Faker::Name.name }
		phone { Faker::PhoneNumber.phone_number }
		email { Faker::Internet.safe_email }

		trait :with_venues do
			venues { FactoryGirl.build_list(:venue, rand(3) + 1) }
		end
	end
end
