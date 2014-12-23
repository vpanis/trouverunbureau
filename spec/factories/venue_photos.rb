# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue_photo do
    photo "MyString"
    
    venue { FactoryGirl.build(:venue) }
  end
end
