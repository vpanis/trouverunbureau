require 'rails_helper'

RSpec.describe Venue, :type => :model do
	subject { FactoryGirl.create(:venue) }

	# Relations
	it { should belong_to(:owner) }
	it { should have_many(:spaces) }
	it { should have_many(:day_hours) }
	it { should have_many(:photos) }

	# Presence
	it { should validate_presence_of(:town) }
	it { should validate_presence_of(:street) }
	it { should validate_presence_of(:postal_code) }
	it { should validate_presence_of(:email) }
	it { should validate_presence_of(:latitude) }
	it { should validate_presence_of(:longitude) }
  	it { should validate_presence_of(:name) }
  	it { should validate_presence_of(:description) }
  	it { should validate_presence_of(:currency) }
  	it { should validate_presence_of(:v_type) }
  	it { should validate_presence_of(:vat_tax_rate) }
  	it { should validate_presence_of(:owner) }

	it { should validate_presence_of(:rating) }
	it { should validate_presence_of(:quantity_reviews) }
	it { should validate_presence_of(:reviews_sum) }

	it { should_not validate_presence_of(:floors) }
	it { should_not validate_presence_of(:rooms) }
	it { should_not validate_presence_of(:desks) }

	# Inclusion
	it { should validate_inclusion_of(:v_type).in_array(Venue::TYPES) }
	it { should validate_inclusion_of(:space_unit).in_array(Venue::SPACE_UNIT_TYPES) }

	# Numericality
	it { should validate_numericality_of(:rating).
		is_less_than_or_equal_to(5).
		is_greater_than_or_equal_to(0) }
	it { should validate_numericality_of(:latitude).
		is_less_than_or_equal_to(90).
		is_greater_than_or_equal_to(-90) }
	it { should validate_numericality_of(:longitude).
		is_less_than_or_equal_to(180).
		is_greater_than_or_equal_to(-180) }
	it { should validate_numericality_of(:space).
		is_greater_than_or_equal_to(0) }
	it { should validate_numericality_of(:vat_tax_rate).
		is_greater_than_or_equal_to(0) }
	it { should validate_numericality_of(:floors).
		only_integer.is_greater_than_or_equal_to(0) }
	it { should validate_numericality_of(:rooms).
		only_integer.is_greater_than_or_equal_to(0) }
	it { should validate_numericality_of(:desks).
		only_integer.is_greater_than_or_equal_to(0) }
	it { should validate_numericality_of(:quantity_reviews).
		only_integer.is_greater_than_or_equal_to(0) }
	it { should validate_numericality_of(:reviews_sum).
		only_integer.is_greater_than_or_equal_to(0) }
end
