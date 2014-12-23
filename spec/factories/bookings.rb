# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :booking do
    state :pending_authorization
    from { Time.now.at_beginning_of_hour.advance(hour: 1) }
    to { Time.now.at_beginning_of_hour.advance(hour: 2) }
    b_type :hour
    quantity 1

    user { FactoryGirl.build(:user) }
    space { FactoryGirl.build(:space) }    
  end
end
