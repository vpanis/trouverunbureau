require 'rails_helper'

RSpec.describe Booking, type: :model do
  subject { FactoryGirl.create(:booking) }

  # Relations
  it { should belong_to(:owner) }
  it { should belong_to(:space) }

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

  context 'trying to check availability' do

    before(:each) do
      @user = FactoryGirl.create(:user)
      @venue = FactoryGirl.create(:venue, :with_venue_hours)
      @space = FactoryGirl.create(:space, venue: @venue, quantity: 4)
      @next_monday_at_beginning = Time.new.next_week(:monday).at_beginning_of_day
      @next_monday_at_beginning = Time.zone.local_to_utc(@next_monday_at_beginning)
      @booking_h_1 = FactoryGirl.create(:booking, state: Booking.states[:paid],
        from: @next_monday_at_beginning.advance(hours: 8),
        to: @next_monday_at_beginning.advance(hours: 19).at_end_of_hour,
        b_type: Booking.b_types[:hour], quantity: 1, owner: @user, space: @space)
      @booking_h_2 = FactoryGirl.create(:booking, state: Booking.states[:paid],
        from: @next_monday_at_beginning.advance(days: 1, hours: 8),
        to: @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour,
        b_type: Booking.b_types[:hour], quantity: 1, owner: @user, space: @space)
      @booking_h_3 = FactoryGirl.create(:booking, state: Booking.states[:paid],
        from: @next_monday_at_beginning.advance(days: 2, hours: 8),
        to: @next_monday_at_beginning.at_end_of_hour.advance(days: 2, hours: 12, minutes: -30),
        b_type: Booking.b_types[:hour], quantity: 2, owner: @user, space: @space)
      @booking_h_4 = FactoryGirl.create(:booking, state: Booking.states[:paid],
        from: @next_monday_at_beginning.advance(days: 2, hours: 15, minutes: 30),
        to: @next_monday_at_beginning.advance(days: 2, hours: 19).at_end_of_hour,
        b_type: Booking.b_types[:hour], quantity: 2, owner: @user, space: @space)
      @booking_d_1 = FactoryGirl.create(:booking, state: Booking.states[:paid],
        from: @next_monday_at_beginning.advance(hours: 8),
        to: @next_monday_at_beginning.advance(days: 2, hours: 19).at_end_of_hour,
        b_type: Booking.b_types[:day], quantity: 2, owner: @user, space: @space)
      @booking_d_2 = FactoryGirl.create(:booking, state: Booking.states[:paid],
        from: @next_monday_at_beginning.advance(hours: 8),
        to: @next_monday_at_beginning.advance(hours: 19).at_end_of_hour,
        b_type: Booking.b_types[:day], quantity: 1, owner: @user, space: @space)

      # monday: full (4), tuesday: (3), wednesday: full (4, only available from 12:30 to 15:30)
    end

    it 'fails when try to book on a full day (monday)' do
      from = @next_monday_at_beginning.advance(hours: 8)
      to = @next_monday_at_beginning.advance(hours: 19).at_end_of_hour
      expect(Booking.bookable?(@space, Booking.b_types[:hour], from, to, 1)).to be(false)
    end

    it 'returns true when try to book on an available day' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      expect(Booking.bookable?(@space, Booking.b_types[:hour], from, to, 1)).to be(true)
    end

    it 'fails when try to book on an available day but with a higher quantity' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      expect(Booking.bookable?(@space, Booking.b_types[:hour], from, to, 2)).to be(false)
    end

    it 'fails when try to book on an available day but with a unavailable range' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 8)
      to = @next_monday_at_beginning.advance(days: 2, hours: 19).at_end_of_hour
      expect(Booking.bookable?(@space, Booking.b_types[:hour], from, to, 1)).to be(false)
    end

    it 'returns true when try to book on an available day in a available range' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 12, minutes: 30)
      to = @next_monday_at_beginning.at_end_of_hour.advance(days: 2, hours: 15, minutes: -30)
      expect(Booking.bookable?(@space, Booking.b_types[:hour], from, to, 1)).to be(true)
    end

    it 'fails when quantity is smaller than 1' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      errors = Booking.check_availability(@space, Booking.b_types[:hour], from, to, 0)
      expect(errors[0][:type]).to be(:invalid_quantity)
    end

    it 'fails when quantity is greater than the space quantity' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      errors = Booking.check_availability(@space, Booking.b_types[:hour], from, to, 5)
      expect(errors[0][:type]).to be(:quantity_exceed_max)
    end

    it 'fails when \'from\' is greater than \'to\'' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      errors = Booking.check_availability(@space, Booking.b_types[:hour], from, to, 1)
      expect(errors[0][:type]).to be(:from_date_bigger_than_to)
    end

    context 'booking for hours' do
      it 'fails when the venue is not open in part of the range for that day' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 7)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        errors = Booking.check_availability(@space, Booking.b_types[:hour], from, to, 1)
        expect(errors[0][:type]).to be(:invalid_venue_hours)
      end
    end

    context 'booking for days' do
      it 'fails when the venue is not open in one day of the range' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 7)
        to = @next_monday_at_beginning.advance(days: 5, hours: 19).at_end_of_hour
        errors = Booking.check_availability(@space, Booking.b_types[:day], from, to, 1)
        expect(errors[0][:type]).to be(:invalid_venue_hours)
      end
    end
  end

end
