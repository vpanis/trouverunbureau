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

        context 'when filtering by venue' do
          let(:venue2) { create(:venue, owner: @user_logged) }
          let(:space2) { create(:space, venue: venue2) }
          let!(:booking6) { create(:booking, space: space2, state: Booking.states[:paid]) }
          let!(:booking7) { create(:booking, space: space2, state: Booking.states[:canceled]) }

          before do
            venue_ids = [venue1.id]
            get :venue_paid_bookings, venue_ids: venue_ids
          end

          it 'succeeds' do
            expect(response.status).to eq(200)
          end

          it 'assigns the requested venue paid bookings to @paid' do
            expect(assigns(:paid).count).to eq(1)
            expect(assigns(:paid).first).to eq(booking1)
          end

          it 'assigns the requested venue canceled bookings to @canceled' do
            expect(assigns(:canceled).count).to eq(1)
            expect(assigns(:canceled).first).to eq(booking2)
          end

          it 'does not retrieve other bookings venue' do
            expect(assigns(:paid).any? do |p|
              p == booking6
            end).to be false
            expect(assigns(:canceled).any? do |p|
              p == booking7
            end).to be false
          end
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
        context 'when user has permissions' do
          context 'when booking owner deletes booking' do
            context 'when paid booking' do
              let!(:book1) { create(:booking, owner: @user_logged, state: Booking.states[:paid]) }
              before do
                delete :destroy, id: book1.id
                book1.reload
              end
              it 'removes only from owner_delete' do
                expect(book1.owner_delete).to eq(true)
                expect(book1.venue_owner_delete).to eq(false)
              end
            end
            context 'when cancelled booking' do
              let!(:b2) { create(:booking, owner: @user_logged, state: Booking.states[:canceled]) }
              before do
                delete :destroy, id: b2.id
                b2.reload
              end
              it 'removes only from owner_delete' do
                expect(b2.owner_delete).to eq(true)
                expect(b2.venue_owner_delete).to eq(false)
              end
            end
          end

          context 'when venue owner deletes booking' do
            let(:venue1) { create(:venue, owner: @user_logged) }
            let(:space1) { create(:space, venue: venue1) }
            context 'when paid booking' do
              let!(:book1) { create(:booking, space: space1, state: Booking.states[:paid]) }
              before do
                delete :destroy, id: book1.id
                book1.reload
              end
              it 'removes only from owner_delete' do
                expect(book1.owner_delete).to eq(false)
                expect(book1.venue_owner_delete).to eq(true)
              end
            end
            context 'when cancelled booking' do
              let!(:b2) { create(:booking, space: space1, state: Booking.states[:canceled]) }
              before do
                delete :destroy, id: b2.id
                b2.reload
              end
              it 'removes only from owner_delete' do
                expect(b2.owner_delete).to eq(false)
                expect(b2.venue_owner_delete).to eq(true)
              end
            end
          end

          context 'when venue and booking owner deletes booking' do
            let(:venue1) { create(:venue, owner: @user_logged) }
            let(:sp1) { create(:space, venue: venue1) }
            context 'when paid booking' do
              let!(:book1) do
                create(:booking, space: sp1, owner: @user_logged, state: Booking.states[:paid])
              end
              before do
                delete :destroy, id: book1.id
                book1.reload
              end
              it 'removes from owner_delete and venue_owner_delete' do
                expect(book1.owner_delete).to eq(true)
                expect(book1.venue_owner_delete).to eq(true)
              end
            end
            context 'when cancelled booking' do
              let!(:b2) do
                create(:booking, space: sp1, owner: @user_logged, state: Booking.states[:canceled])
              end
              before do
                delete :destroy, id: b2.id
                b2.reload
              end
              it 'removes from owner_delete and venue_owner_delete' do
                expect(b2.owner_delete).to eq(true)
                expect(b2.venue_owner_delete).to eq(true)
              end
            end
          end
        end

        context 'when user does not have permissions' do
          let(:booking1) { create(:booking, state: Booking.states[:canceled]) }
          before do
            delete :destroy, id: booking1.id
          end
          it 'fails' do
            expect(response.status).to eq(403)
          end
        end # when user does not have permissions
      end # when booking exists

      context 'when booking does not exists' do
        before do
          delete :destroy, id: -1
        end
        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when booking does not exists

    end # when user logged in

  end # DELETE bookings/:id/delete
end
