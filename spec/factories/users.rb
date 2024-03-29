# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |e| "#{e}_#{Faker::Internet.safe_email}" }
    phone { Faker::PhoneNumber.phone_number }
    password { Faker::Internet.password }
    profession { Venue::PROFESSIONS.first.to_s }
    company_name { Faker::Company.name }
    gender { 'f' }
    nationality 'FR'
    country_of_residence 'FR'
    date_of_birth { Time.current.advance(years: -21) }

    trait :with_venues do
      venues { FactoryGirl.build_list(:venue, rand(3) + 1) }
    end

    trait :with_venues_with_spaces do
      venues { FactoryGirl.build_list(:venue, rand(3) + 1, :with_spaces) }
    end
  end
end
