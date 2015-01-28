require 'rails_helper'

RSpec.describe BookingManager, type: :model do

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

  context 'trying to check availability' do

    it 'returns false when ask if it\'s bookeable on a full day (monday)' do
      from = @next_monday_at_beginning.advance(hours: 8)
      to = @next_monday_at_beginning.advance(hours: 19).at_end_of_hour
      expect(BookingManager.bookable?(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                      from: from, to: to, quantity: 1)).to be(false)
    end

    it 'returns true when ask if it\'s bookeable on an available day' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      expect(BookingManager.bookable?(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                      from: from, to: to, quantity: 1)).to be(true)
    end

    it 'returns false ask if it\'s bookeable on an available day but with a higher quantity' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      expect(BookingManager.bookable?(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                      from: from, to: to, quantity: 2)).to be(false)
    end

    it 'returns false ask if it\'s bookeable on an available day but with a unavailable range' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 8)
      to = @next_monday_at_beginning.advance(days: 2, hours: 19).at_end_of_hour
      expect(BookingManager.bookable?(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                      from: from, to: to, quantity: 1)).to be(false)
    end

    it 'returns true when ask if it\'s bookeable on an available day in a available range' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 12, minutes: 30)
      to = @next_monday_at_beginning.at_end_of_hour.advance(days: 2, hours: 15, minutes: -30)
      expect(BookingManager.bookable?(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                      from: from, to: to, quantity: 1)).to be(true)
    end

    it 'fails when quantity is greater than the space quantity' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      booking = BookingManager.book(owner: @user, space: @space,
        b_type: Booking.b_types[:hour], from: from, to: to, quantity: 5)
      expect(booking.errors[:quantity_exceed_max]).to be_present
    end

    it 'fails when \'from\' is greater than \'to\'' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      booking = BookingManager.book(owner: @user, space: @space,
        b_type: Booking.b_types[:hour], from: from, to: to, quantity: 1)
      expect(booking.errors[:from_date_bigger_than_to]).to be_present
    end

    context 'booking for hours' do
      it 'fails when the venue is not open in part of the range for that day' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 7)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        booking = BookingManager.book(owner: @user, space: @space,
          b_type: Booking.b_types[:hour], from: from, to: to, quantity: 1)
        expect(booking.errors[:invalid_venue_hours]).to be_present
      end
    end

    context 'booking for days' do
      it 'fails when the venue is not open in one day of the range' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 7)
        to = @next_monday_at_beginning.advance(days: 5, hours: 19).at_end_of_hour
        booking = BookingManager.book(owner: @user, space: @space,
          b_type: Booking.b_types[:day], from: from, to: to, quantity: 1)
        expect(booking.errors[:invalid_venue_hours]).to be_present
      end
    end
  end

  context 'trying to book the space' do

    it 'fails when tries to book on a full day (monday)' do
      from = @next_monday_at_beginning.advance(hours: 8)
      to = @next_monday_at_beginning.advance(hours: 19).at_end_of_hour
      expect(BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                 from: from, to: to, quantity: 1).created_at?).to be(false)
    end

    it 'returns the booking when tries to book on an available day' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      expect(BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                 from: from, to: to, quantity: 1).created_at?).to be(true)
    end

    it 'fails when tries to book on an available day but with a higher quantity' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      expect(BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                 from: from, to: to, quantity: 2).created_at?).to be(false)
    end

    it 'fails when tries to book on an available day but with a unavailable range' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 8)
      to = @next_monday_at_beginning.advance(days: 2, hours: 19).at_end_of_hour
      expect(BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                 from: from, to: to, quantity: 1).created_at?).to be(false)
    end

    it 'returns the booking when tries to book on an available day in a available range' do
      from = @next_monday_at_beginning.advance(days: 2, hours: 12, minutes: 30)
      to = @next_monday_at_beginning.at_end_of_hour.advance(days: 2, hours: 15, minutes: -30)
      expect(BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                 from: from, to: to, quantity: 1).created_at?).to be(true)
    end
  end

  context 'change a pending_authorization booking to pending_payment' do
    it 'returns a booking with state pending_payment if success' do
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      booking = BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                 from: from, to: to, quantity: 1)
      expect(booking.errors.empty?).to be(true)
      expect(BookingManager.change_to_pending_payment(booking).state).to eq('pending_payment')
    end

    it 'returns a booking with state already_taken if fails' do
      # One space left
      from = @next_monday_at_beginning.advance(days: 1, hours: 8)
      to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
      # creates 2 pending_authorization bookings

      booking1 = BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                     from: from, to: to, quantity: 1)
      expect(booking1.errors.empty?).to be(true)
      booking2 = BookingManager.book(owner: @user, space: @space, b_type: Booking.b_types[:hour],
                                     from: from, to: to, quantity: 1)
      expect(booking2.errors.empty?).to be(true)
      # pending_payment booking1
      expect(BookingManager.change_to_pending_payment(booking1).state).to eq('pending_payment')
      # already_taken booking2
      expect(BookingManager.change_to_pending_payment(booking2).state).to eq('already_taken')
    end
  end

end
