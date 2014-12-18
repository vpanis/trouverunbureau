# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue do
    town Faker::Address.city
    street Faker::Address.street_address
    postal_code Faker::Address.postcode
    phone Faker::PhoneNumber.phone_number
    email Faker::Internet.safe_email
    website Faker::Internet.url('example.com')
    latitude Faker::Address.latitude
    longitude Faker::Address.longitude
    name Faker::Name.name
    description Faker::Lorem.sentence
    currency :ars
    logo "MyString"
    type Venue::TYPES.sample
    space 1.5
    space_unit Venue::SPACE_UNIT_TYPES.sample
    floors 1
    rooms 5
    desks 40
    vat_tax_rate 1.5
    amenities Venue::AMENITY_TYPES.sample(3)
    owner FactoryGirl.build(:user)
  end
end
