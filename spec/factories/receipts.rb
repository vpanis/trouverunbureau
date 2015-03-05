# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :receipt do
    booking { FactoryGirl.create(:booking) }
  end
end
