# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue_review do
    message { Faker::Lorem.sentence }
    stars { rand(5) + 1 }
    active true

    venue { FactoryGirl.build(:venue) }
    from_user { FactoryGirl.build(:user, :with_venues_with_spaces) }

    after(:build) do |venue_review|
      venue = venue_review.from_user.venues.first if venue_review.from_user.present?
      return if venue_review.booking.present? || venue.nil? || venue.spaces.empty?

      venue_review.booking = FactoryGirl.build(:booking,
                                               owner: venue_review.from_user,
                                               space: venue.spaces.first)
    end
  end
end
