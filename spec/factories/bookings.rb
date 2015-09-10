# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :booking do
    state Booking.states[:pending_authorization]
    from { Time.current.at_beginning_of_hour.advance(hours: 1) }
    to { Time.current.at_end_of_hour.advance(hours: 1) }
    b_type Booking.b_types[:hour]
    quantity 1
    deposit 0

    owner { FactoryGirl.build(:user) }
    space { FactoryGirl.build(:space) }
  end
end
