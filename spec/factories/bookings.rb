# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :booking do
    state Booking.states[:pending_authorization]
    from { Time.now.at_beginning_of_hour.advance(hour: 1) }
    to { Time.now.at_end_of_hour.advance(hour: 1) }
    b_type Booking.b_types[:hour]
    quantity 1

    owner { FactoryGirl.build(:user) }
    space { FactoryGirl.build(:space) }
  end
end
