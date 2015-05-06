# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_zone do
    zone_identifier 'Europe/Paris'
    minute_utc_difference 7200
  end
end
