require 'rails_helper'

RSpec.describe VenuePhoto, :type => :model do
	subject { FactoryGirl.create(:venue_photo) }

	# Relations
	it { should belong_to(:venue) }
	it { should belong_to(:space) }

	# Presence
	it { should validate_presence_of(:venue) }
end
