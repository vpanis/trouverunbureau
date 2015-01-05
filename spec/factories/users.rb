# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :user do
		first_name { Faker::Name.first_name }
		last_name { Faker::Name.last_name }
		email { Faker::Internet.safe_email }
		phone { Faker::PhoneNumber.phone_number }
		language :en

		trait :with_venues do
			venues { FactoryGirl.build_list(:venue, rand(3) + 1) }
		end
	end
end
