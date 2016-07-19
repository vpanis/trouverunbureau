require 'rails_helper'

RSpec.describe SpaceSearch, type: :model do
  # let(:resource) { FactoryGirl.create :device }
  # let(:type)     { Type.find resource.type_id }

  before(:all) do
    @v1 = FactoryGirl.create(:venue, v_type: Venue.v_types[:startup_office], latitude: 10,
                             longitude: 10, amenities: ['wifi'],
                             professions: %w(technology public_relations),
                             rating: 4, quantity_reviews: 10,
                             day_hours: [create(:venue_hour, weekday: 0)])
    @v2 = FactoryGirl.create(:venue, v_type: Venue.v_types[:design_studio], latitude: 20,
                             longitude: 20, amenities: ['cafe_restaurant'],
                             professions: ['public_relations'],
                             rating: 5, quantity_reviews: 10,
                             day_hours: [create(:venue_hour, weekday: 1)])
    @v3 = FactoryGirl.create(:venue, v_type: Venue.v_types[:business_center], latitude: 30,
                             longitude: 30, amenities: ['kitchen'],
                             professions: ['entertainment'],
                             rating: 5, quantity_reviews: 3,
                             day_hours: [create(:venue_hour, weekday: 2)])
    @v4 = FactoryGirl.create(:venue, v_type: Venue.v_types[:startup_office], latitude: 40,
                             longitude: 40, amenities: %w(wifi gym),
                             professions: %w(public_relations technology),
                             rating: 4, quantity_reviews: 20,
                             day_hours: [create(:venue_hour, weekday: 0),
                                         create(:venue_hour, weekday: 3)])
    @v5 = FactoryGirl.create(:venue, v_type: Venue.v_types[:corporate_office], latitude: 50,
                             longitude: 50, amenities: ['cafe_restaurant'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 10,
                             day_hours: [create(:venue_hour, weekday: 2)])
    @v6 = FactoryGirl.create(:venue, v_type: Venue.v_types[:hotel], latitude: 60,
                             longitude: 60, amenities: ['cafe_restaurant'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 40,
                             day_hours: [create(:venue_hour, weekday: 2)])

    @v7 = FactoryGirl.create(:venue, v_type: Venue.v_types[:loft], latitude: 60,
                             longitude: 60, amenities: ['wifi'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 30,
                             day_hours: [create(:venue_hour, weekday: 2)])

    @v8 = FactoryGirl.create(:venue, v_type: Venue.v_types[:coworking_space], latitude: 60,
                             longitude: 60, amenities: ['kitchen'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 40,
                             day_hours: [create(:venue_hour, weekday: 1)])

    @v9 = FactoryGirl.create(:venue, v_type: Venue.v_types[:apartment], latitude: 55,
                             longitude: 60, amenities: ['wifi'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 20,
                             day_hours: [create(:venue_hour, weekday: 4)])

    @v10 = FactoryGirl.create(:venue, v_type: Venue.v_types[:house], latitude: 60,
                             longitude: 60, amenities: ['kitchen'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 40,
                             day_hours: [create(:venue_hour, weekday: 5)])

    @v11 = FactoryGirl.create(:venue, v_type: Venue.v_types[:cafe], latitude: 60,
                             longitude: 60, amenities: ['cafe_restaurant'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 40,
                             day_hours: [create(:venue_hour, weekday: 1)])

    @v12 = FactoryGirl.create(:venue, v_type: Venue.v_types[:restaurant], latitude: 60,
                             longitude: 60, amenities: ['cafe_restaurant'],
                             professions: ['public_relations'],
                             rating: 4, quantity_reviews: 40,
                             day_hours: [create(:venue_hour, weekday: 1)])

    @s1_v1 = FactoryGirl.create(:space, venue: @v1, s_type: Space.s_types[:hot_desk],
                                capacity: 1, quantity: 1)
    @s2_v1 = FactoryGirl.create(:space, venue: @v1, s_type: Space.s_types[:private_office],
                                capacity: 1, quantity: 1)

    @s1_v2 = FactoryGirl.create(:space, venue: @v2, s_type: Space.s_types[:hot_desk],
                                capacity: 2, quantity: 2)
    @s2_v2 = FactoryGirl.create(:space, venue: @v2, s_type: Space.s_types[:meeting_room],
                                capacity: 2, quantity: 2)

    @s1_v3 = FactoryGirl.create(:space, venue: @v3, s_type: Space.s_types[:private_office],
                                capacity: 3, quantity: 3)

    @s2_v4 = FactoryGirl.create(:space, venue: @v4, s_type: Space.s_types[:meeting_room],
                                capacity: 4, quantity: 4)
    @s1_v5 = FactoryGirl.create(:space, venue: @v5, s_type: Space.s_types[:private_office],
                                capacity: 1, quantity: 1)
    @s1_v6 = FactoryGirl.create(:space, venue: @v6, s_type: Space.s_types[:private_office],
                                capacity: 1, quantity: 1)
    @s1_v7 = FactoryGirl.create(:space, venue: @v7, s_type: Space.s_types[:hot_desk],
                                capacity: 1, quantity: 1)
    @s1_v8 = FactoryGirl.create(:space, venue: @v8, s_type: Space.s_types[:hot_desk],
                                capacity: 1, quantity: 1)
    @s1_v9 = FactoryGirl.create(:space, venue: @v9, s_type: Space.s_types[:hot_desk],
                                capacity: 1, quantity: 1)
    @s1_v10 = FactoryGirl.create(:space, venue: @v10, s_type: Space.s_types[:hot_desk],
                                capacity: 1, quantity: 1)
    @s1_v11 = FactoryGirl.create(:space, venue: @v11, s_type: Space.s_types[:hot_desk],
                                capacity: 1, quantity: 1)
    @s1_v12 = FactoryGirl.create(:space, venue: @v12, s_type: Space.s_types[:hot_desk],
                                capacity: 1, quantity: 1)
  end

  context 'search setting only space_types' do

    it 'returns the spaces with :hot_desk' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:hot_desk]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s1_v2, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end

    it 'returns the spaces with :private_office' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:private_office]])
      expect(ss.find_spaces).to contain_exactly(@s2_v1, @s1_v3, @s1_v5, @s1_v6)
    end

    it 'returns the spaces with :meeting_room' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:meeting_room]])
      expect(ss.find_spaces).to contain_exactly(@s2_v2, @s2_v4)
    end

    it 'returns the spaces with :private_office or :hot_desk' do
      ss = SpaceSearch.new(space_types: [Space.s_types[:private_office], Space.s_types[:hot_desk]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s1_v2, @s2_v1, @s1_v3, @s1_v5, @s1_v6,
                                                @s1_v7, @s1_v8, @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end

    it 'returns every space' do
      ss = SpaceSearch.new(space_types: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end

  end

  context 'search setting only venue_types' do

    it 'returns the spaces with :startup_office' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:startup_office]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s2_v4)
    end

    it 'returns the spaces with :design_studio' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:design_studio]])
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2)
    end

    it 'returns the spaces with :business_center' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:business_center]])
      expect(ss.find_spaces).to contain_exactly(@s1_v3)
    end

    it 'returns the spaces with :corporate_office' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:corporate_office]])
      expect(ss.find_spaces).to contain_exactly(@s1_v5)
    end

    it 'returns the spaces with :hotel' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:hotel]])
      expect(ss.find_spaces).to contain_exactly(@s1_v6)
    end

    it 'returns the spaces with :loft' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:loft]])
      expect(ss.find_spaces).to contain_exactly(@s1_v7)
    end

    it 'returns the spaces with :coworking_space' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:coworking_space]])
      expect(ss.find_spaces).to contain_exactly(@s1_v8)
    end

    it 'returns the spaces with :apartment' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:apartment]])
      expect(ss.find_spaces).to contain_exactly(@s1_v9)
    end

    it 'returns the spaces with :house' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:house]])
      expect(ss.find_spaces).to contain_exactly(@s1_v10)
    end

    it 'returns the spaces with :cafe' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:cafe]])
      expect(ss.find_spaces).to contain_exactly(@s1_v11)
    end

    it 'returns the spaces with :restaurant' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:restaurant]])
      expect(ss.find_spaces).to contain_exactly(@s1_v12)
    end

    it 'returns the spaces with :design_studio or :startup_office' do
      ss = SpaceSearch.new(venue_types: [Venue.v_types[:design_studio],
                                         Venue.v_types[:startup_office]])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2, @s2_v4)
    end

    it 'returns every space' do
      ss = SpaceSearch.new(venue_types: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting only venue_amenities' do

    it 'returns the spaces that contains \'wifi\'' do
      ss = SpaceSearch.new(venue_amenities: ['wifi'])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s2_v4, @s1_v7, @s1_v9)
    end

    it 'returns the spaces that contains \'cafe_restaurant\'' do
      ss = SpaceSearch.new(venue_amenities: ['cafe_restaurant'])
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2, @s1_v5, @s1_v6, @s1_v11, @s1_v12)
    end

    it 'returns the spaces with \'gym\' and \'wifi\'' do
      ss = SpaceSearch.new(venue_amenities: %w(gym wifi))
      expect(ss.find_spaces).to contain_exactly(@s2_v4)
    end

    it 'returns every space' do
      ss = SpaceSearch.new(venue_amenities: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting only venue_professions' do

    it 'returns the spaces that contains \'technology\'' do
      ss = SpaceSearch.new(venue_professions: ['technology'])
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s2_v4)
    end

    it 'returns the spaces that contains \'entertainment\'' do
      ss = SpaceSearch.new(venue_professions: ['entertainment'])
      expect(ss.find_spaces).to contain_exactly(@s1_v3)
    end

    it 'returns the spaces that contains \'entertainment\' or \'technology\'' do
      ss = SpaceSearch.new(venue_professions: %w(entertainment technology))
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v3, @s2_v4)
    end

    it 'returns every space' do
      ss = SpaceSearch.new(venue_professions: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
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

    it 'returns every space' do
      ss = SpaceSearch.new(latitude_from: nil, longitude_from: 0,
                           latitude_to: nil, longitude_to: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting only capacity_min' do

    it 'returns the spaces with capacity greater than 3 when setted to 4' do
      ss = SpaceSearch.new(capacity_min: 4)
      expect(ss.find_spaces).to contain_exactly(@s2_v4)
    end

    it 'returns the spaces with capacity greater than 2 when setted to 3' do
      ss = SpaceSearch.new(capacity_min: 3)
      expect(ss.find_spaces).to contain_exactly(@s1_v3, @s2_v4)
    end

    it 'returns an empty array when there are no spaces with that capacity' do
      ss = SpaceSearch.new(capacity_min: 10)
      expect(ss.find_spaces).to contain_exactly
    end

    it 'returns every space' do
      ss = SpaceSearch.new(capacity_min: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting only capacity_max' do

    it 'returns the spaces with capacity lower or equal than 4 when setted to 4' do
      ss = SpaceSearch.new(capacity_max: 4)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2, @s1_v3,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8, @s1_v9, @s1_v10,
                                                @s1_v11, @s1_v12, @s2_v4)
    end

    it 'returns the spaces with capacity lower or equal than 3 when setted to 3' do
      ss = SpaceSearch.new(capacity_max: 3)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2, @s1_v3,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8, @s1_v9, @s1_v10,
                                                @s1_v11, @s1_v12)
    end

    it 'returns an empty array when there are no spaces with that capacity' do
      ss = SpaceSearch.new(capacity_max: 0)
      expect(ss.find_spaces).to contain_exactly
    end

    it 'returns every space' do
      ss = SpaceSearch.new(capacity_max: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting only quantity' do

    it 'returns the spaces with quantity greater than 3 when setted to 4' do
      ss = SpaceSearch.new(quantity: 4)
      expect(ss.find_spaces).to contain_exactly(@s2_v4)
    end

    it 'returns the spaces with quantity greater than 2 when setted to 3' do
      ss = SpaceSearch.new(quantity: 3)
      expect(ss.find_spaces).to contain_exactly(@s1_v3, @s2_v4)
    end

    it 'returns an empty array when there are no spaces with that quantity' do
      ss = SpaceSearch.new(quantity: 10)
      expect(ss.find_spaces).to contain_exactly
    end

    it 'returns every space' do
      ss = SpaceSearch.new(quantity: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting only weekday' do

    it 'returns the spaces with venue hours weekday 0' do
      ss = SpaceSearch.new(weekday: 0)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s2_v4)
    end

    it 'returns the spaces with venue hours weekday 1' do
      ss = SpaceSearch.new(weekday: 1)
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2, @s1_v8, @s1_v11, @s1_v12)
    end

    it 'returns an empty array when there are no spaces with that weekday' do
      ss = SpaceSearch.new(weekday: 6)
      expect(ss.find_spaces).to contain_exactly
    end

    it 'returns every space' do
      ss = SpaceSearch.new(weekday: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting only date' do

    it 'returns the spaces with venue hours with weekday monday' do
      next_monday = Time.current.next_week
      ss = SpaceSearch.new(date: next_monday.to_s)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s2_v4)
    end

    it 'returns the spaces with venue hours with weekday tuesday' do
      next_monday = Time.current.next_week
      ss = SpaceSearch.new(date: next_monday.advance(days: 1).to_s)
      expect(ss.find_spaces).to contain_exactly(@s1_v2, @s2_v2, @s1_v8, @s1_v11, @s1_v12)
    end

    it 'returns an empty array when there are no spaces with weekday sunday' do
      next_monday = Time.current.next_week
      ss = SpaceSearch.new(date: next_monday.advance(days: 6).to_s)
      expect(ss.find_spaces).to contain_exactly
    end

    it 'returns every space' do
      ss = SpaceSearch.new(date: nil)
      expect(ss.find_spaces).to contain_exactly(@s1_v1, @s2_v1, @s1_v2, @s2_v2,
                                                @s1_v3, @s2_v4,
                                                @s1_v5, @s1_v6, @s1_v7, @s1_v8,
                                                @s1_v9, @s1_v10, @s1_v11, @s1_v12)
    end
  end

  context 'search setting multiple fields' do

    it 'returns the spaces with weekday monday, startup_office, \'wifi\', and a meeting_room' do
      next_monday = Time.current.next_week
      ss = SpaceSearch.new(date: next_monday.to_s,
                           venue_types: [Venue.v_types[:startup_office]],
                           venue_amenities: ['wifi'],
                           space_types: [Space.s_types[:meeting_room]])
      expect(ss.find_spaces).to contain_exactly(@s2_v4)
    end

    it 'returns the spaces ordered by quantity_reviews and rating' do
      ss = SpaceSearch.new(venue_amenities: ['wifi'],
                           space_types: [Space.s_types[:hot_desk],
                                         Space.s_types[:meeting_room]])
      expect(ss.find_spaces).to match_array([@s1_v1, @s1_v7, @s1_v9, @s2_v4])
    end

  end
end
