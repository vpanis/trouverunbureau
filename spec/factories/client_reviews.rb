# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :client_review do
    message { Faker::Lorem.sentence }
    stars { rand(5) + 1 }
    active true

    client { FactoryGirl.build(:user) }
    from_user { FactoryGirl.build(:user, :with_venues_with_spaces) }

    after(:build) do |client_review|
      venue = client_review.from_user.venues.first if client_review.from_user.present?
      return if client_review.booking.present? || venue.nil? || venue.spaces.empty?

      client_review.booking = FactoryGirl.build(:booking,
                                                owner: client_review.client,
                                                space: venue.spaces.first)
    end
  end
end
