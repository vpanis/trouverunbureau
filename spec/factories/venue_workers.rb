# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :venue_worker do
    user nil
    venue nil
    role "MyString"
  end
end
