require 'rails_helper'

RSpec.describe BookingManager, type: :model do

  context 'reservations' do
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
        expect(BookingManager.bookable?({ owner: @user, space: @space,
                                        b_type: Booking.b_types[:hour], from: from, to: to,
                                        quantity: 1 }, 'check_if_can_book_and_perform'))
                             .to be(false)
      end

      it 'returns true when ask if it\'s bookeable on an available day' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        expect(BookingManager.bookable?({ owner: @user, space: @space,
                                        b_type: Booking.b_types[:hour], from: from, to: to,
                                        quantity: 1 }, 'check_if_can_book_and_perform'))
                             .to be(true)
      end

      it 'returns false ask if it\'s bookeable on an available day but with a higher quantity' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        expect(BookingManager.bookable?({ owner: @user, space: @space,
                                        b_type: Booking.b_types[:hour], from: from, to: to,
                                        quantity: 2 }, 'check_if_can_book_and_perform'))
                             .to be(false)
      end

      it 'returns false ask if it\'s bookeable on an available day but with a unavailable range' do
        from = @next_monday_at_beginning.advance(days: 2, hours: 8)
        to = @next_monday_at_beginning.advance(days: 2, hours: 19).at_end_of_hour
        expect(BookingManager.bookable?({ owner: @user, space: @space,
                                        b_type: Booking.b_types[:hour], from: from, to: to,
                                        quantity: 1 }, 'check_if_can_book_and_perform'))
                             .to be(false)
      end

      it 'returns true when ask if it\'s bookeable on an available day in a available range' do
        from = @next_monday_at_beginning.advance(days: 2, hours: 12, minutes: 30)
        to = @next_monday_at_beginning.at_end_of_hour.advance(days: 2, hours: 15, minutes: -30)
        expect(BookingManager.bookable?({ owner: @user, space: @space,
                                        b_type: Booking.b_types[:hour], from: from, to: to,
                                        quantity: 1 }, 'check_if_can_book_and_perform'))
                             .to be(true)
      end

      it 'fails when quantity is greater than the space quantity' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        _booking, errors = BookingManager.book(@user, owner: @user, space: @space,
                                               b_type: Booking.b_types[:hour],
                                               from: from, to: to, quantity: 5)
        expect(errors[:quantity_exceed_max]).to be_present
      end

      it 'fails when \'from\' is greater than \'to\'' do
        from = @next_monday_at_beginning.advance(days: 2, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        _booking, errors = BookingManager.book(@user, owner: @user, space: @space,
                                               b_type: Booking.b_types[:hour],
                                               from: from, to: to, quantity: 1)
        expect(errors[:from_date_bigger_than_to]).to be_present
      end

      context 'booking for hours' do
        it 'fails when the venue is not open in part of the range for that day' do
          from = @next_monday_at_beginning.advance(days: 1, hours: 7)
          to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
          _booking, errors = BookingManager.book(@user, owner: @user, space: @space,
                                                 b_type: Booking.b_types[:hour],
                                                 from: from, to: to, quantity: 1)
          expect(errors[:invalid_venue_hours]).to be_present
        end
      end

      context 'booking for days' do
        it 'fails when the venue is not open in one day of the range' do
          from = @next_monday_at_beginning.advance(days: 1, hours: 7)
          to = @next_monday_at_beginning.advance(days: 5, hours: 19).at_end_of_hour
          _booking, errors = BookingManager.book(@user, owner: @user, space: @space,
                                                 b_type: Booking.b_types[:day],
                                                 from: from, to: to, quantity: 1)
          expect(errors[:invalid_venue_hours]).to be_present
        end
      end
    end

    context 'trying to book the space' do

      it 'fails when tries to book on a full day (monday)' do
        from = @next_monday_at_beginning.advance(hours: 8)
        to = @next_monday_at_beginning.advance(hours: 19).at_end_of_hour
        expect(BookingManager.book(@user, owner: @user, space: @space,
                                          b_type: Booking.b_types[:hour], from: from,
                                          to: to, quantity: 1)[0].created_at?).to be(false)
      end

      it 'returns the booking when tries to book on an available day' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        expect(BookingManager.book(@user, owner: @user, space: @space,
                                          b_type: Booking.b_types[:hour], from: from,
                                          to: to, quantity: 1)[0].created_at?).to be(true)
      end

      it 'fails when tries to book on an available day but with a higher quantity' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        expect(BookingManager.book(@user, owner: @user, space: @space,
                                          b_type: Booking.b_types[:hour], from: from,
                                          to: to, quantity: 2)[0].created_at?).to be(false)
      end

      it 'fails when tries to book on an available day but with a unavailable range' do
        from = @next_monday_at_beginning.advance(days: 2, hours: 8)
        to = @next_monday_at_beginning.advance(days: 2, hours: 19).at_end_of_hour
        expect(BookingManager.book(@user, owner: @user, space: @space,
                                          b_type: Booking.b_types[:hour], from: from,
                                          to: to, quantity: 1)[0].created_at?).to be(false)
      end

      it 'returns the booking when tries to book on an available day in a available range' do
        from = @next_monday_at_beginning.advance(days: 2, hours: 12, minutes: 30)
        to = @next_monday_at_beginning.at_end_of_hour.advance(days: 2, hours: 15, minutes: -30)
        expect(BookingManager.book(@user, owner: @user, space: @space,
                                          b_type: Booking.b_types[:hour], from: from,
                                          to: to, quantity: 1)[0].created_at?).to be(true)
      end
    end

    context 'change a pending_authorization booking to pending_payment' do
      it 'returns a booking with state pending_payment if success' do
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        booking, errors = BookingManager.book(@user, owner: @user, space: @space,
                                               b_type: Booking.b_types[:hour],
                                               from: from, to: to, quantity: 1)
        expect(booking.errors.empty? && errors.empty?).to be(true)
        expect(BookingManager.change_booking_status(@space.venue.owner, booking,
                                                    Booking.states[:pending_authorization])[0]
          .state).to eq('pending_payment')
      end

      it 'returns a booking with state pending_authorization and collition_errors if fails' do
        # One space left
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour
        # creates 2 pending_authorization bookings

        p_authorization = Booking.states[:pending_authorization]

        booking1, errors1 = BookingManager.book(@user, owner: @user, space: @space,
                                                b_type: Booking.b_types[:hour],
                                                from: from, to: to, quantity: 1)
        expect(booking1.errors.empty? && errors1.empty?).to be(true)
        booking2, errors2 = BookingManager.book(@user, owner: @user, space: @space,
                                                b_type: Booking.b_types[:hour],
                                                from: from, to: to, quantity: 1)
        expect(booking2.errors.empty? && errors2.empty?).to be(true)
        # pending_payment booking1
        expect(BookingManager.change_booking_status(@space.venue.owner, booking1,
                                                    p_authorization)[0]
        .state).to eq('pending_payment')
        # pending_payment booking2
        booking2, custom_errors = BookingManager.change_booking_status(@space.venue.owner,
                                                                       booking2, p_authorization)
        expect(booking2.state).to eq('pending_authorization')
        expect(custom_errors[:collition_errors]).to be_present
      end
    end

    context 'update booking attributes' do

      before(:each) do
        from = @next_monday_at_beginning.advance(days: 1, hours: 8)
        to = @next_monday_at_beginning.advance(days: 1, hours: 19).at_end_of_hour

        @booking, @errors = BookingManager.book(@user, owner: @user, space: @space,
                                                b_type: Booking.b_types[:hour],
                                                from: from, to: to, quantity: 1)
        expect(@errors.empty?).to be true
      end

      it 'return success if the venue\'s owner change the price' do
        @booking, errors = BookingManager.update_booking(@venue.owner, @booking,
                                                         price: @booking.price + 15)
        expect(errors.empty?).to be true
      end

      it 'return success if the venue\'s owner change the quantity' do
        @booking, errors = BookingManager.update_booking(@venue.owner, @booking,
                                                         quantity: @booking.quantity - 1)
        expect(errors.empty?).to be true
      end

      it 'fails if the venue\'s owner change the quantity and there\'s no space' do
        @booking, errors = BookingManager.update_booking(@venue.owner, @booking,
                                                         quantity: @space.quantity + 1)
        expect(errors.empty?).to be false
      end
    end
  end

  context 'messages from BookingInquiry' do

    before(:each) do
      @owner1 = FactoryGirl.create(:organization)
      @owner1_u1 = @owner1.users[0]
      @venue1 = FactoryGirl.create(:venue, :with_venue_hours, owner: @owner1)
      @space1 = FactoryGirl.create(:space, venue: @venue1, quantity: 4)
      @owner2 = FactoryGirl.create(:user)
      @venue2 = FactoryGirl.create(:venue, :with_venue_hours, owner: @owner2)
      @space2 = FactoryGirl.create(:space, venue: @venue2, quantity: 4)

      @next_monday_at_beginning = Time.new.next_week(:monday).at_beginning_of_day
      @next_monday_at_beginning = Time.zone.local_to_utc(@next_monday_at_beginning)

      @from = @next_monday_at_beginning.advance(hours: 8)
      @to = @next_monday_at_beginning.advance(hours: 19, days: 4).at_end_of_hour

      @booking1, @errors1 = BookingManager.book(@owner1_u1, from: @from, to: @to,
                                                b_type: Booking.b_types[:hour],
                                                quantity: 1, owner: @owner1,
                                                space: @space2)[0]
      @booking2, @errors2 = BookingManager.book(@owner2, from: @from, to: @to,
                                                b_type: Booking.b_types[:hour],
                                                quantity: 1, owner: @owner2,
                                                space: @space1)[0]
      @booking3, @errors3 = BookingManager.book(@owner1_u1, from: @from, to: @to,
                                                b_type: Booking.b_types[:hour],
                                                quantity: 1, owner: @owner1,
                                                space: @space1)[0]
    end

    context 'retrieving the bookings that have news' do
      it 'returns the booking to the venue\'s owner when created' do
        expect(BookingManager.bookings_with_news(@owner2)).to include(@booking1)
      end

      it 'don\'t return the booking to owner when created' do
        expect(BookingManager.bookings_with_news(@owner1)).not_to include(@booking1)
      end

      it 'don\'t return the booking when created if owner its both' do
        expect(BookingManager.bookings_with_news(@owner1)).not_to include(@booking3)
      end

      it 'don\'t return the booking to the last owner that send a message' do
        FactoryGirl.create(:message, user: @owner2, represented: @owner2, booking: @booking1)
        expect(BookingManager.bookings_with_news(@owner2)).not_to include(@booking1)
      end

      it 'return the booking to the owner that didn\'t send the last message' do
        expect(BookingManager.bookings_with_news(@owner1)).not_to include(@booking1)
        FactoryGirl.create(:message, user: @owner2, represented: @owner2, booking: @booking1)
        expect(BookingManager.bookings_with_news(@owner2)).not_to include(@booking1)
        expect(BookingManager.bookings_with_news(@owner1)).to include(@booking1)
      end

      it 'don\'t return the booking if the user already read the messages' do
        expect(BookingManager.bookings_with_news(@owner2)).to include(@booking1)
        BookingManager.change_last_seen(@booking1, @owner2, Time.now)
        expect(BookingManager.bookings_with_news(@owner2)).not_to include(@booking1)
      end

      it 'return the booking if the venue\'s owner change the price' do
        expect(BookingManager.bookings_with_news(@owner1)).not_to include(@booking1)
        @booking1, @errors1 = BookingManager.update_booking(@owner2, @booking1,
                                                            price: @booking1.price + 15)
        expect(@errors1.empty?).to be true
        expect(BookingManager.bookings_with_news(@owner2)).not_to include(@booking1)
        expect(BookingManager.bookings_with_news(@owner1)).to include(@booking1)
      end

      it 'return the booking if the venue\'s owner change the quantity' do
        expect(BookingManager.bookings_with_news(@owner1)).not_to include(@booking1)
        @booking1, @errors1 = BookingManager.update_booking(@owner2, @booking1,
                                                            quantity: @booking1.quantity + 1)
        expect(@errors1.empty? && @booking1.valid?).to be true
        expect(BookingManager.bookings_with_news(@owner2)).not_to include(@booking1)
        expect(BookingManager.bookings_with_news(@owner1)).to include(@booking1)
      end

      it 'fails if the venue\'s owner change the quantity and there\'s no space' do
        @booking1, @errors1 = BookingManager.update_booking(@owner2, @booking1,
                                                            quantity: @booking1.space.quantity + 1)
        expect(@errors1.empty?).to be false
      end
    end
  end

end
