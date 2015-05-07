# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :time_zone do
    # Use all the timezones with 0 offset as default, because the app time is utc
    zone_identifier do
      Timezone::Zone.list.select { |z| z[:offset] == 0 }.map { |z| z[:zone] }.sample
    end
    minute_utc_difference 0
  end
end
