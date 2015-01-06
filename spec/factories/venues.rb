# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue do
    town { Faker::Address.city }
    street { Faker::Address.street_address }
    postal_code { Faker::Address.postcode }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.safe_email }
    website { Faker::Internet.url('example.com') }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    currency :ars
    v_type { Venue::TYPES.sample.to_s }
    space 1.5
    space_unit { Venue::SPACE_UNIT_TYPES.sample.to_s }
    floors 1
    rooms 5
    desks 40
    vat_tax_rate 1.5
    amenities { Venue::AMENITY_TYPES.sample(3).map(&:to_s) }
    logo Rack::Test::UploadedFile.new(File.open(File.join(
      Rails.root, '/spec/fixtures/dropkick.png')))

    owner { FactoryGirl.build(:user) }

    trait :with_spaces do
      spaces { FactoryGirl.build_list(:space, rand(3) + 1) }
    end
  end
end
