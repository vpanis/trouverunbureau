require 'rails_helper'

RSpec.describe VenueHour, :type => :model do
	subject { FactoryGirl.create(:venue_hour) }

	# Relations
	it { should belong_to(:venue) }

	# Presence
	it { should validate_presence_of(:venue) }
	it { should validate_presence_of(:from) }
	it { should validate_presence_of(:to) }
	it { should validate_presence_of(:weekday) }

	# Numericality
	it { should validate_numericality_of(:weekday).
		only_integer.
		is_less_than(7).
		is_greater_than_or_equal_to(0) }

	it "should raise exception for repeated days for the same venue" do
		venue_hours = FactoryGirl.create(:venue_hour)
		expect { 
			FactoryGirl.create(:venue_hour, venue: venue_hours.venue, weekday: venue_hours.weekday) 
		}.to raise_exception
	end
end
