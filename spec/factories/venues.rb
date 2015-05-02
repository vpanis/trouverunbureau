# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue do
    town { Faker::Address.city }
    street { Faker::Address.street_address }
    postal_code { Faker::Address.postcode }
    phone { Faker::PhoneNumber.phone_number }
    sequence(:email) { |e| "#{e}_#{Faker::Internet.safe_email}" }
    website { Faker::Internet.url('example.com') }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    currency 'eur'
    v_type { Venue.v_types.values.sample }
    space 1.5
    space_unit { Venue.space_units.values.sample }
    floors 1
    rooms 5
    desks 40
    vat_tax_rate 1.5
    amenities { Venue::AMENITY_TYPES.sample(3).map(&:to_s) }
    professions { Venue::PROFESSIONS.sample(2).map(&:to_s) }
    logo Rack::Test::UploadedFile.new(File.open(File.join(
      Rails.root, '/spec/fixtures/dropkick.png')))

    owner { FactoryGirl.build(:user) }
    country_code 'FR'
    trait :with_spaces do
      spaces { FactoryGirl.build_list(:space, rand(3) + 1) }
    end

    # Only for Factorygirl.CREATE, nested_attributes issues
    trait :with_venue_hours do
      after(:create) do |venue|
        FactoryGirl.create(:venue_hour, venue: venue, weekday: 0)
        FactoryGirl.create(:venue_hour, venue: venue, weekday: 1)
        FactoryGirl.create(:venue_hour, venue: venue, weekday: 2)
        FactoryGirl.create(:venue_hour, venue: venue, weekday: 3)
        FactoryGirl.create(:venue_hour, venue: venue, weekday: 4)
      end
    end
  end
end
