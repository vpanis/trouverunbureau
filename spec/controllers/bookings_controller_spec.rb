require 'rails_helper'

describe BookingsController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) do
    create(:user)
  end

  describe 'GET bookings/paid_bookings' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      context 'when user has paid or cancelled bookings' do
        let!(:booking1) { create(:booking, owner: @user_logged, state: Booking.states[:paid]) }
        let!(:booking2) { create(:booking, owner: @user_logged, state: Booking.states[:canceled]) }
        let!(:booking3) { create(:booking, state: Booking.states[:paid]) }
        let!(:booking4) { create(:booking, state: Booking.states[:canceled]) }
        let!(:booking5) { create(:booking, owner: @user_logged, state: Booking.states[:denied]) }

        it 'succeeds' do
          get :paid_bookings
          expect(response.status).to eq(200)
        end

        it 'assigns the requested paid bookings to @paid' do
          get :paid_bookings
          expect(assigns(:paid).count).to eq(1)
          expect(assigns(:paid).first).to eq(booking1)
        end

        it 'assigns the requested cancelled bookings to @canceled' do
          get :paid_bookings
          expect(assigns(:canceled).count).to eq(1)
          expect(assigns(:canceled).first).to eq(booking2)
        end

        it 'renders the :paid_bookings template' do
          get :paid_bookings
          expect(response).to render_template :paid_bookings
        end

      end # when user has paid or cancelled bookings

    end # when user logged in
  end # GET bookings/paid_bookings

  describe 'GET bookings/venue_paid_bookings' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      context 'when user has paid or cancelled bookings' do
        let(:venue1) { create(:venue, owner: @user_logged) }
        let(:space1) { create(:space, venue: venue1) }
        let!(:booking1) { create(:booking, space: space1, state: Booking.states[:paid]) }
        let!(:booking2) { create(:booking, space: space1, state: Booking.states[:canceled]) }
        let!(:booking3) { create(:booking, state: Booking.states[:paid]) }
        let!(:booking4) { create(:booking, state: Booking.states[:canceled]) }
        let!(:booking5) { create(:booking, space: space1, state: Booking.states[:denied]) }

        it 'succeeds' do
          get :venue_paid_bookings
          expect(response.status).to eq(200)
        end

        it 'assigns the requested venue paid bookings to @paid' do
          get :venue_paid_bookings
          expect(assigns(:paid).count).to eq(1)
          expect(assigns(:paid).first).to eq(booking1)
        end

        it 'assigns the requested venue cancelled bookings to @canceled' do
          get :venue_paid_bookings
          expect(assigns(:canceled).count).to eq(1)
          expect(assigns(:canceled).first).to eq(booking2)
        end

        it 'renders the :venue_paid_bookings template' do
          get :venue_paid_bookings
          expect(response).to render_template :venue_paid_bookings
        end

      end # when user has paid or cancelled bookings

    end # when user logged in
  end # GET bookings/venue_paid_bookings

  describe 'DELETE bookings/:id/delete' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      context 'when booking exists' do
        let(:venue1) { create(:venue, owner: @user_logged) }
        let(:space1) { create(:space, venue: venue1) }
        let!(:booking1) { create(:booking, space: space1, state: Booking.states[:paid]) }
        let!(:booking2) { create(:booking, space: space1, state: Booking.states[:canceled]) }
        let!(:booking3) { create(:booking, state: Booking.states[:paid]) }
        let!(:booking4) { create(:booking, state: Booking.states[:canceled]) }
        let!(:booking5) { create(:booking, space: space1, state: Booking.states[:denied]) }

        context 'when user has permissions' do

        end

        context 'when user does not have permissions' do
          let(:booking1) { create(:booking, state: Booking.states[:canceled]) }
          before do
            patch :delete, id: booking1.id
          end
          it 'fails' do
            expect(response.status).to eq(403)
          end
        end # when user does not have permissions
      end # when booking exists

      context 'when booking does not exists' do
        before do
          patch :delete, id: -1
        end
        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when booking does not exists

    end # when user logged in

  end # DELETE bookings/:id/delete
end
