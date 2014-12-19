# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue_photo do
    venue nil
    photo "MyString"
  end
end
