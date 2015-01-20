require 'rails_helper'

RSpec.describe SpaceSearch, type: :model do
  # let(:resource) { FactoryGirl.create :device }
  # let(:type)     { Type.find resource.type_id }

  before(:all) do
    @v1 = FactoryGirl.create(:venue, v_type: Venue.v_types[:startup_office], latitude: 10, longitude: 10, 
                            amenities: ["wifi"])
    FactoryGirl.create(:venue_hour, venue: @v1, weekday: 0)
    @v2 = FactoryGirl.create(:venue, v_type: Venue.v_types[:studio], latitude: 20, longitude: 20, 
                            amenities: ["cafe_restaurant"])
    FactoryGirl.create(:venue_hour, venue: @v2, weekday: 1)
    @v3 = FactoryGirl.create(:venue, v_type: Venue.v_types[:bussines_center], latitude: 30, longitude: 30, 
                            amenities: ["catering_available"])
    FactoryGirl.create(:venue_hour, venue: @v3, weekday: 2)
    @v4 = FactoryGirl.create(:venue, v_type: Venue.v_types[:startup_office], latitude: 40, longitude: 40, 
                            amenities: ["wifi", "lockers"])
    FactoryGirl.create(:venue_hour, venue: @v4, weekday: 0)
    FactoryGirl.create(:venue_hour, venue: @v4, weekday: 3)

    @s1_v1 = FactoryGirl.create(:space, venue: @v1, s_type: Space.s_types[:desk], capacity: 1, quantity: 1)
    @s2_v1 = FactoryGirl.create(:space, venue: @v1, s_type: Space.s_types[:office], capacity: 1, quantity: 1)

    @s1_v2 = FactoryGirl.create(:space, venue: @v2, s_type: Space.s_types[:desk], capacity: 2, quantity: 2)
    @s2_v2 = FactoryGirl.create(:space, venue: @v2, s_type: Space.s_types[:meeting_room], capacity: 2, quantity: 2)

    @s1_v3 = FactoryGirl.create(:space, venue: @v3, s_type: Space.s_types[:office], capacity: 3, quantity: 3)
    @s2_v3 = FactoryGirl.create(:space, venue: @v3, s_type: Space.s_types[:conference_room], capacity: 3, quantity: 3)

    @s1_v4 = FactoryGirl.create(:space, venue: @v4, s_type: Space.s_types[:conference_room], capacity: 4, quantity: 4)
    @s2_v4 = FactoryGirl.create(:space, venue: @v4, s_type: Space.s_types[:meeting_room], capacity: 4, quantity: 4)
  end

  context 'search setting only space_types' do

    it 'returns only the :desk spaces when setted with :desk' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:desk]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s1_v2)
    end

    it 'returns only the :office spaces when setted with :office' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:office]])
      expect(ss.find_spaces).to contain_exactly(@s2_v1, @s1_v3)
    end

    it 'returns the :office and :desk spaces when setted with :office and :desk' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:office], Space.s_types[:desk]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s1_v2, @s2_v1, @s1_v3)
    end

  end

  context 'search setting only venue_types' do

    it 'returns only the :startup_office spaces when setted with :startup_office' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:startup_office]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v4, @s2_v4)
    end

    it 'returns only the :studio spaces when setted with :studio' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:studio]])
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2)
    end

    it 'returns the :studio and :startup_office spaces when setted with :studio and :startup_office' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:studio], Venue.v_types[:startup_office]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2, @s1_v4, @s2_v4)
    end

  end

  context 'search setting only venue_amenities' do

    it 'returns only the spaces with the amenity \'wifi\' when setted with \'wifi\'' do
      ss = SpaceSearch.new(venue_amenities: ['wifi'])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v4, @s2_v4)
    end

    it 'returns only the spaces with the amenity \'cafe_restaurant\' when setted with \'cafe_restaurant\'' do
      ss = SpaceSearch.new(venue_amenities: ['cafe_restaurant'])
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2)
    end

    it 'returns the spaces with the amenities \'lockers\' and \'wifi\' when setted with \'lockers\' and \'wifi\'' do
      ss = SpaceSearch.new(venue_amenities: ['lockers', 'wifi'])
      expect(ss.find_spaces).to contain_exactly(@s1_v4, @s2_v4)
    end

  end

  context 'search setting only latitude and longitude' do

    it 'returns the spaces between (5,5) and (15, 15)' do
      ss = SpaceSearch.new(latitude_from: 5, longitude_from: 5, latitude_to: 15, longitude_to: 15)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1)
    end

    it 'returns the spaces between (5,5) and (25, 25)' do
      ss = SpaceSearch.new(latitude_from: 5, longitude_from: 5, latitude_to: 25, longitude_to: 25)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2)
    end

    it 'returns an empty array between (0,0) and (5, 5)' do
      ss = SpaceSearch.new(latitude_from: 0, longitude_from: 0, latitude_to: 5, longitude_to: 5)
      expect(ss.find_spaces).to contain_exactly()
    end

  end

  context 'search setting only latitude and longitude' do

    it 'returns the spaces between (5,5) and (15, 15)' do
      ss = SpaceSearch.new(latitude_from: 5, longitude_from: 5, latitude_to: 15, longitude_to: 15)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1)
    end

    it 'returns the spaces between (5,5) and (25, 25)' do
      ss = SpaceSearch.new(latitude_from: 5, longitude_from: 5, latitude_to: 25, longitude_to: 25)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2)
    end

    it 'returns an empty array between (0,0) and (5, 5)' do
      ss = SpaceSearch.new(latitude_from: 0, longitude_from: 0, latitude_to: 5, longitude_to: 5)
      expect(ss.find_spaces).to contain_exactly()
    end

  end
end
