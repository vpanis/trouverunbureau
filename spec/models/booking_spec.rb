require 'rails_helper'

RSpec.describe Booking, type: :model do
  subject { FactoryGirl.create(:booking) }

  # Relations
  it { should belong_to(:owner) }
  it { should belong_to(:space) }
  it { should have_many(:messages) }

  # Presence
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:space) }
  it { should validate_presence_of(:b_type) }
  it { should validate_presence_of(:quantity) }
  it { should validate_presence_of(:from) }
  it { should validate_presence_of(:to) }

  # Enums
  it { should define_enum_for(:b_types) }
  it { should define_enum_for(:states) }

  # Numericality
  it do
    should validate_numericality_of(:quantity)
    .only_integer.is_greater_than_or_equal_to(1)
  end

  it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }

  it { should validate_numericality_of(:fee).is_greater_than_or_equal_to(0) }

  it { should validate_numericality_of(:deposit).is_greater_than_or_equal_to(0) }

  it 'should fail if the space don\'t have the booking type price' do
    space = FactoryGirl.create(:space, day_price: 10, month_price: nil)
    booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:month])
    expect(booking.valid?).to be(false)
    expect(booking.errors[:price_not_found_for_b_type]).to be_present
  end

  context 'price calculation' do
    before(:each) do
      @venue = FactoryGirl.create(:venue,
                                  day_hours: [create(:venue_hour, weekday: 1, from: 800, to: 2000),
                                              create(:venue_hour, weekday: 2, from: 800, to: 2000),
                                              create(:venue_hour, weekday: 4, from: 800, to: 2000)]
                                  )
      # open: tuesday, wednesday and friday
      @space = FactoryGirl.create(:space, venue: @venue, hour_price: 2, day_price: 20,
                                  week_price: 100, month_price: 400)
      @monday = Time.current.next_week(:monday).at_beginning_of_day
    end

    it 'returns the calculated hour price for 10 hours, 1 space' do
      from = @monday.advance(days: 1, hours: 10)
      to = @monday.advance(days: 1, hours: 19).at_end_of_hour
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:hour],
                                   from: from, to: to, quantity: 1)
      expect(booking.price).to eq(2 * 10)
    end

    it 'returns the calculated hour price for 10 hours, 2 space' do
      from = @monday.advance(days: 1, hours: 10)
      to = @monday.advance(days: 1, hours: 19).at_end_of_hour
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:hour],
                                   from: from, to: to, quantity: 2)
      expect(booking.price).to eq(2 * 10 * 2)
    end

    it 'returns the calculated day price for 2 days, 1 space' do
      from = @monday.advance(days: 1)
      to = @monday.advance(days: 2).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:day],
                                   from: from, to: to, quantity: 1)
      expect(booking.price).to eq(20 * 2)
    end

    it 'returns the calculated day price for 2 days, 2 spaces' do
      from = @monday.advance(days: 1)
      to = @monday.advance(days: 2).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:day],
                                   from: from, to: to, quantity: 2)
      expect(booking.price).to eq(20 * 2 * 2)
    end

    it 'returns the calculated day price for 10 days (when venue opens), 1 space' do
      from = @monday
      to = @monday.advance(days: 9).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:day],
                                   from: from, to: to, quantity: 1)
      expect(booking.price).to eq(20 * 5)
    end

    it 'returns the calculated day price for 14 days (when venue opens), 1 space' do
      from = @monday
      to = @monday.advance(days: 13).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:day],
                                   from: from, to: to, quantity: 1)
      expect(booking.price).to eq(20 * 6)
    end

    it 'returns the calculated day price for 14 days (when venue opens), 2 spaces' do
      from = @monday
      to = @monday.advance(days: 13).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:day],
                                   from: from, to: to, quantity: 2)
      expect(booking.price).to eq(20 * 6 * 2)
    end

    it 'returns the calculated week price for 2 weeks, 1 space' do
      from = @monday
      # beggining of monday to end of sunday in 13 days
      to = @monday.advance(weeks: 2, days: -1).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:week],
                                   from: from, to: to, quantity: 1)
      expect(booking.price).to eq(100 * 2)
    end

    it 'returns the calculated week price for 2 weeks, 2 space' do
      from = @monday
      # beggining of monday to end of sunday in 13 days
      to = @monday.advance(weeks: 2, days: -1).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:week],
                                   from: from, to: to, quantity: 2)
      expect(booking.price).to eq(100 * 2 * 2)
    end

    it 'returns the calculated month price for 2 months, 1 space' do
      from = @monday
      # if we add 1 month and then ask for the end of that day its 1 month and 1 day,
      # and that will calculate the price of 2 months
      to = @monday.advance(months: 2, days: -1).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:month],
                                   from: from, to: to, quantity: 1)
      expect(booking.price).to eq(400 * 2)
    end

    it 'returns the calculated month price for 2 months, 1 day, 1 space' do
      from = @monday
      to = @monday.advance(months: 2, days: 1).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:month],
                                   from: from, to: to, quantity: 1)
      # one day exceeded paying for months its one more month
      expect(booking.price).to eq(400 * 3)
    end

    it 'returns the calculated month price for 2 months, 2 space' do
      from = @monday
      # if we add 1 month and then ask for the end of that day its 1 month and 1 day,
      # and that will calculate the price of 2 months
      to = @monday.advance(months: 2, days: -1).at_end_of_day
      booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:month],
                                   from: from, to: to, quantity: 2)
      expect(booking.price).to eq(400 * 2 * 2)
    end
  end

  context 'fee calculation' do
    it 'returns the fee to pay to deskspotting' do
      booking = FactoryGirl.create(:booking, price: 300, fee: 0)
      expect(booking.fee).to eq(booking.price * Rails.configuration.payment.deskspotting_fee)
    end
  end

  context 'minimum unity' do
    it 'returns an error if the space minimum hours is not reached' do
      space = FactoryGirl.create(:space, hour_minimum_unity: 5)
      from = Time.current.at_beginning_of_day
      to = from.advance(hours: 1).at_end_of_hour
      booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:hour],
                                  from: from, to: to)
      expect(booking.valid?).to be(false)
      expect(booking.errors[:minimum_time]).to be_present
    end

    it 'returns an error if the space minimum days is not reached' do
      space = FactoryGirl.create(:space, day_minimum_unity: 5)
      from = Time.current.at_beginning_of_day
      to = from.advance(days: 1).at_end_of_day
      booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:day],
                                  from: from, to: to)
      expect(booking.valid?).to be(false)
      expect(booking.errors[:minimum_time]).to be_present
    end

    it 'returns an error if the space minimum days is not reached with open days' do
      from = Time.current.at_beginning_of_day
      to = from.advance(days: 6).at_end_of_day
      venue = FactoryGirl.create(:venue, day_hours: [])
      expect(venue.day_hours.size).to be(1)
      venue.day_hours.first.update_attributes(weekday: (from.wday - 1) % 7)
      space = FactoryGirl.create(:space, venue: venue, day_minimum_unity: 2)
      booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:day],
                                  from: from, to: to)
      expect(booking.valid?).to be(false)
      expect(booking.errors[:minimum_time]).to be_present
    end

    it 'returns no error if the space minimum days is reached with open days' do
      from = Time.current.at_beginning_of_day
      to = from.advance(days: 7).at_end_of_day
      venue = FactoryGirl.create(:venue, day_hours: [])
      expect(venue.day_hours.size).to be(1)
      venue.day_hours.first.update_attributes(weekday: (from.wday - 1) % 7)
      space = FactoryGirl.create(:space, venue: venue, day_minimum_unity: 2)
      booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:day],
                                  from: from, to: to)
      expect(booking.valid?).to be(true)
    end

    it 'returns an error if the space minimum weeks is not reached' do
      space = FactoryGirl.create(:space, week_minimum_unity: 5)
      from = Time.current.at_beginning_of_day
      to = from.advance(weeks: 1).at_end_of_day
      booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:week],
                                  from: from, to: to)
      expect(booking.valid?).to be(false)
      expect(booking.errors[:minimum_time]).to be_present
    end

    it 'returns an error if the space minimum months is not reached' do
      space = FactoryGirl.create(:space, month_minimum_unity: 5)
      from = Time.current.at_beginning_of_day
      to = from.advance(months: 1).at_end_of_day
      booking = FactoryGirl.build(:booking, space: space, b_type: Booking.b_types[:month],
                                  from: from, to: to)
      expect(booking.valid?).to be(false)
      expect(booking.errors[:minimum_time]).to be_present
    end
  end
end
