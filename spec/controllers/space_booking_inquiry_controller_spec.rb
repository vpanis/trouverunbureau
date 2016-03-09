require 'rails_helper'

describe SpaceBookingInquiryController do

  describe 'GET /spaces/:id/inquiry' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      context 'when the space exists' do
        let(:a_venue) { create(:venue) }
        let!(:a_space) { create(:space, venue: a_venue) }

        it 'succeeds' do
          get :inquiry, id: a_space.id
          expect(response.status).to eq(200)
        end

        it 'fails' do
          get :inquiry, id: -1
          expect(response.status).to eq(404)
        end
      end
    end

    context 'when user is not logged in' do
      it 'fails' do
        get :inquiry, id: 1
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'POST /spaces/:id/inquiry' do
    context 'when user logged in' do
      let(:a_venue) { create(:venue, :with_venue_hours) }
      let!(:a_space) do
        create(:space, venue: a_venue, hour_price: 5, day_price: 30,
        month_price: 800, month_to_month_price: 600)
      end

      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
        @time = Time.current.next_week(:monday)
        @from = @time.strftime('%d-%m-%Y')
        @to = @time.advance(days: 2).strftime('%d-%m-%Y')
      end

      after(:each) do
        sign_out @user_logged
      end

      context 'when booking params are valid' do
        context 'without text message' do
          before do
            expect(@user_logged.bookings.count).to be(0)

            post :create_booking_inquiry, id: a_space.id, booking: { from: @from,
              to: @to, quantity: 1 }, booking_type: 'day'
            expect(response.status).to eq(302)
          end

          it 'creates a new booking' do
            expect(@user_logged.bookings.count).to be(1)
          end

          it 'creates a \'pending_authorization\' message' do
            expect(@user_logged.bookings.last.messages.last.m_type).to eq('pending_authorization')
          end
        end
        context 'with text temessage' do
          before do
            expect(@user_logged.bookings.count).to be(0)
            post :create_booking_inquiry, id: a_space.id, booking: { from: @from, to: @to,
              quantity: 1 }, booking_type: 'day', message: 'holis'
            expect(response.status).to eq(302)
          end

          it 'creates a \'pending_authorization\' message' do
            expect(@user_logged.bookings.last.messages.count).to be(2)
            expect(@user_logged.bookings.last.messages.where(
              m_type: Message.m_types[:pending_authorization]).count).to be(1)
          end

          it 'creates the text message' do
            expect(@user_logged.bookings.last.messages.count).to be(2)
            expect(@user_logged.bookings.last.messages.find_by_m_type(Message.m_types[:text]).text)
              .to eq('holis')
          end
        end
      end

      context 'when booking type is not valid' do
        it 'fails' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: 1 },
            booking_type: '', hour_booking_from: '08:00', hour_booking_to: '16:00'
          expect(response.status).to eq(400)
        end
      end

      context 'when an hour booking is created' do
        it 'succeeds' do
          expect(@user_logged.bookings.count).to be(0)
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: 1 },
            booking_type: 'hour', hour_booking_from: '08:00', hour_booking_to: '16:00'
          expect(@user_logged.bookings.count).to be(1)
        end

        it 'fails caused by wrong from date' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: '', quantity: 1 },
            booking_type: 'hour', hour_booking_from: '08:00', hour_booking_to: '16:00'
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong quantity' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: -1 },
            booking_type: 'hour', hour_booking_from: '08:00', hour_booking_to: '16:00'
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong hour booking from' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: 1 },
            booking_type: 'hour', hour_booking_from: '', hour_booking_to: '16:00'
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong hour booking to' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: 1 },
            booking_type: 'hour', hour_booking_from: '08:00', hour_booking_to: ''
          expect(response.status).to eq(400)
        end
      end

      context 'when a day booking is created' do
        it 'succeeds' do
          expect(@user_logged.bookings.count).to be(0)
          post :create_booking_inquiry, id: a_space.id,
            booking: { from: @from, to: @to, quantity: 1 }, booking_type: 'day'
          expect(@user_logged.bookings.count).to be(1)
        end

        it 'fails caused by wrong from date' do
          post :create_booking_inquiry, id: a_space.id,
            booking: { from: '', to: @to, quantity: 1 }, booking_type: 'day'
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong to date' do
          post :create_booking_inquiry, id: a_space.id,
            booking: { from: @from,  to: '', quantity: 1 }, booking_type: 'day'
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong quantity' do
          post :create_booking_inquiry, id: a_space.id,
            booking: { from: @from,  to: @to, quantity: -1 }, booking_type: 'day'
          expect(response.status).to eq(400)
        end
      end

      context 'when a month booking is created' do
        it 'succeeds' do
          expect(@user_logged.bookings.count).to be(0)
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: 1 },
            booking_type: 'month', month_quantity: 1
          expect(@user_logged.bookings.count).to be(1)
        end

        it 'fails caused by wrong from date' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: '', quantity: 1 },
            booking_type: 'month', month_quantity: 1
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong quantity' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: -1 },
            booking_type: 'month', month_quantity: 1
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong month quantity' do
          post :create_booking_inquiry, id: a_space.id, booking: { from: @from, quantity: 1 },
            booking_type: 'month', month_quantity: -1
          expect(response.status).to eq(400)
        end
      end

      context 'when a month to month booking is created' do
        it 'succeeds' do
          expect(@user_logged.bookings.count).to be(0)
          post :create_booking_inquiry, id: a_space.id, booking:
            {
              from: @from,
              quantity: 1,
            },
            booking_type: 'month_to_month'
          expect(@user_logged.bookings.count).to be(1)
        end

        it 'fails caused by wrong from date' do
          post :create_booking_inquiry, id: a_space.id, booking:
            {
              from: '',
              quantity: 1
            },
            booking_type: 'month_to_month'
          expect(response.status).to eq(400)
        end

        it 'fails caused by wrong space quantity' do
          post :create_booking_inquiry, id: a_space.id, booking:
            {
              from: @from,
              quantity: -1
            },
            booking_type: 'month_to_month'
          expect(response.status).to eq(400)
        end
      end
    end

    context 'when user is not logged in' do
      it 'fails' do
        get :inquiry, id: 1
        expect(response.status).to eq(302)
      end
    end
  end

end
