# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    user { FactoryGirl.build(:user) }
    booking { FactoryGirl.build(:booking, owner: user) }
    m_type Message.m_types[:text]
    text { Faker::Lorem.sentence }
  end
end
