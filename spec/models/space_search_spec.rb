require 'rails_helper'

RSpec.describe SpaceSearch, type: :model do
  # let(:resource) { FactoryGirl.create :device }
  # let(:type)     { Type.find resource.type_id }

  before(:all) do
    @v1 = FactoryGirl.create(:venue, v_type: Venue.v_types[:startup_office], latitude: 10,
                             longitude: 10, amenities: ['wifi'],
                             primary_professions: ['technology'],
                             secondary_professions: ['public_relations'],
                             rating: 4, quantity_reviews: 10)
    FactoryGirl.create(:venue_hour, venue: @v1, weekday: 0)
    @v2 = FactoryGirl.create(:venue, v_type: Venue.v_types[:studio], latitude: 20,
                             longitude: 20, amenities: ['cafe_restaurant'],
                             primary_professions: [],
                             secondary_professions: ['public_relations'],
                             rating: 5, quantity_reviews: 10)
    FactoryGirl.create(:venue_hour, venue: @v2, weekday: 1)
    @v3 = FactoryGirl.create(:venue, v_type: Venue.v_types[:business_center], latitude: 30,
                             longitude: 30, amenities: ['kitchen'],
                             primary_professions: ['entertainment'],
                             secondary_professions: [],
                             rating: 5, quantity_reviews: 3)
    FactoryGirl.create(:venue_hour, venue: @v3, weekday: 2)
    @v4 = FactoryGirl.create(:venue, v_type: Venue.v_types[:startup_office], latitude: 40,
                             longitude: 40, amenities: %w(wifi gym),
                             primary_professions: ['public_relations'],
                             secondary_professions: ['technology'],
                             rating: 4, quantity_reviews: 20)
    FactoryGirl.create(:venue_hour, venue: @v4, weekday: 0)
    FactoryGirl.create(:venue_hour, venue: @v4, weekday: 3)

    @s1_v1 = FactoryGirl.create(:space, venue: @v1, s_type: Space.s_types[:desk],
                                capacity: 1, quantity: 1)
    @s2_v1 = FactoryGirl.create(:space, venue: @v1, s_type: Space.s_types[:office],
                                capacity: 1, quantity: 1)

    @s1_v2 = FactoryGirl.create(:space, venue: @v2, s_type: Space.s_types[:desk],
                                capacity: 2, quantity: 2)
    @s2_v2 = FactoryGirl.create(:space, venue: @v2, s_type: Space.s_types[:meeting_room],
                                capacity: 2, quantity: 2)

    @s1_v3 = FactoryGirl.create(:space, venue: @v3, s_type: Space.s_types[:office],
                                capacity: 3, quantity: 3)
    @s2_v3 = FactoryGirl.create(:space, venue: @v3, s_type: Space.s_types[:conference_room],
                                capacity: 3, quantity: 3)

    @s1_v4 = FactoryGirl.create(:space, venue: @v4, s_type: Space.s_types[:conference_room],
                                capacity: 4, quantity: 4)
    @s2_v4 = FactoryGirl.create(:space, venue: @v4, s_type: Space.s_types[:meeting_room],
                                capacity: 4, quantity: 4)
  end

  context 'search setting only space_types' do

    it 'returns the spaces with :desk' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:desk]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s1_v2)
    end

    it 'returns the spaces with :office' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:office]])
      expect(ss.find_spaces).to contain_exactly(@s2_v1, @s1_v3)
    end

    it 'returns the spaces with :office or :desk' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:office], Space.s_types[:desk]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s1_v2, @s2_v1, @s1_v3)
    end

  end

  context 'search setting only venue_types' do

    it 'returns the spaces with :startup_office' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:startup_office]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v4, @s2_v4)
    end

    it 'returns the spaces with :studio' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:studio]])
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2)
    end

    it 'returns the spaces with :studio or :startup_office' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:studio], Venue.v_types[:startup_office]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2, @s1_v4, @s2_v4)
    end

  end

  context 'search setting only venue_amenities' do

    it 'returns the spaces that contains \'wifi\'' do
      ss = SpaceSearch.new(venue_amenities: ['wifi'])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v4, @s2_v4)
    end

    it 'returns the spaces that contains \'cafe_restaurant\'' do
      ss = SpaceSearch.new(venue_amenities: ['cafe_restaurant'])
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2)
    end

    it 'returns the spaces with \'gym\' and \'wifi\'' do
      ss = SpaceSearch.new(venue_amenities: %w(gym wifi))
      expect(ss.find_spaces).to contain_exactly(@s1_v4, @s2_v4)
    end

  end

  context 'search setting only venue_professions' do

    it 'returns the spaces that contains \'technology\'' do
      ss = SpaceSearch.new(venue_professions: ['technology'])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v4, @s2_v4)
    end

    it 'returns the spaces that contains \'entertainment\'' do
      ss = SpaceSearch.new(venue_professions: ['entertainment'])
      expect(ss.find_spaces).to contain_exactly(@s1_v3, @s2_v3)
    end

    it 'returns the spaces that contains \'entertainment\' or \'technology\'' do
      ss = SpaceSearch.new(venue_professions: %w(entertainment technology))
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v3, @s2_v3, @s1_v4, @s2_v4)
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
      expect(ss.find_spaces).to contain_exactly
    end

  end

  context 'search setting only capacity' do

    it 'returns the spaces with capacity grater than 3 when setted to 4' do
      ss = SpaceSearch.new(capacity: 4)
      expect(ss.find_spaces).to contain_exactly(@s1_v4, @s2_v4)
    end

    it 'returns the spaces with capacity grater than 2 when setted to 3' do
      ss = SpaceSearch.new(capacity: 3)
      expect(ss.find_spaces).to contain_exactly(@s1_v3, @s2_v3, @s1_v4, @s2_v4)
    end

    it 'returns an empty array when there are no spaces with that capacity' do
      ss = SpaceSearch.new(capacity: 10)
      expect(ss.find_spaces).to contain_exactly
    end

  end

  context 'search setting only quantity' do

    it 'returns the spaces with quantity grater than 3 when setted to 4' do
      ss = SpaceSearch.new(quantity: 4)
      expect(ss.find_spaces).to contain_exactly(@s1_v4, @s2_v4)
    end

    it 'returns the spaces with quantity grater than 2 when setted to 3' do
      ss = SpaceSearch.new(quantity: 3)
      expect(ss.find_spaces).to contain_exactly(@s1_v3, @s2_v3, @s1_v4, @s2_v4)
    end

    it 'returns an empty array when there are no spaces with that quantity' do
      ss = SpaceSearch.new(quantity: 10)
      expect(ss.find_spaces).to contain_exactly
    end

  end

  context 'search setting only weekday' do

    it 'returns the spaces with venue hours weekday 0' do
      ss = SpaceSearch.new(weekday: 0)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v4, @s2_v4)
    end

    it 'returns the spaces with venue hours weekday 1' do
      ss = SpaceSearch.new(weekday: 1)
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2)
    end

    it 'returns an empty array when there are no spaces with that weekday' do
      ss = SpaceSearch.new(weekday: 6)
      expect(ss.find_spaces).to contain_exactly
    end

  end

  context 'search setting only date' do

    it 'returns the spaces with venue hours with weekday monday' do
      next_monday = Time.new.next_week
      ss = SpaceSearch.new(date: next_monday.to_s)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v4, @s2_v4)
    end

    it 'returns the spaces with venue hours with weekday tuesday' do
      next_monday = Time.new.next_week
      ss = SpaceSearch.new(date: next_monday.advance(days: 1).to_s)
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2)
    end

    it 'returns an empty array when there are no spaces with weekday sunday' do
      next_monday = Time.new.next_week
      ss = SpaceSearch.new(date: next_monday.advance(days: 6).to_s)
      expect(ss.find_spaces).to contain_exactly
    end

  end

  context 'search setting multiple fields' do

    it 'returns the spaces with weekday monday, startup_office, \'wifi\', and a conference_room' do
      next_monday = Time.new.next_week
      ss = SpaceSearch.new(date: next_monday.to_s,
                           venue_types: [Venue.v_types[:startup_office]],
                           venue_amenities: ['wifi'],
                           space_types: [Space.s_types[:conference_room]])
      expect(ss.find_spaces).to contain_exactly(@s1_v4)
    end

    it 'returns the spaces ordered by quantity_reviews and rating' do
      ss = SpaceSearch.new(venue_amenities: ['wifi'],
                           space_types: [Space.s_types[:desk], Space.s_types[:conference_room]])
      expect(ss.find_spaces).to match_array([@s1_v4, @s1_v1])
    end

  end
end
