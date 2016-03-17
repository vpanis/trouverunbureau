require 'rails_helper'

describe SpacesController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) do
    create(:user)
  end

  describe 'GET spaces/:id/edit' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      context 'when the space exists' do
        context 'when has permissions' do
          let(:a_venue) { create(:venue, owner: @user_logged) }
          let!(:a_space) { create(:space, venue: a_venue) }

          it 'succeeds' do
            get :edit, id: a_space.id
            expect(response.status).to eq(200)
          end
          it 'assigns the requested space to @space' do
            get :edit, id: a_space.id
            expect(assigns(:space)).to eq(a_space)
          end

          it 'renders the :edit template' do
            get :edit, id: a_space.id
            expect(response).to render_template :edit
          end
        end # when has permissions

        context ' when has not permissions' do
          let!(:a_space) { create(:space) }
          it 'fails' do
            get :edit, id: a_space.id
            expect(response.status).to eq(403)
          end
        end # when has not permissions
      end # when the space exists

      context 'when the space does not exist' do
        before { get :edit, id: -1 }

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when the space does not exist
    end # when user logged in

    context 'when no user is logged in' do
      let!(:a_space) { create(:space) }
      it 'is redirected to login' do
        get :edit, id: a_space.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end # when no user is logged in
  end # GET spaces/:id/edit

  describe 'UPDATE spaces/:id/update' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end
      context 'when the space exists' do
        context 'when has permissions' do
          let(:a_venue) { create(:venue, owner: @user_logged) }
          let(:a_space) { create(:space, capacity: 2, venue: a_venue) }
          let(:new_description) { 'new description' }
          let(:new_quantity) { a_space.quantity + 1 }
          let(:new_hour_price) { 10 }
          let(:new_hour_deposit) { 5 }
          let(:new_day_price) { 100 }
          let(:new_day_deposit) { 15 }
          let(:new_month_price) { 1000 }
          let(:new_month_deposit) { 150 }
          let(:new_month_to_month_price) { 2000 }
          let(:new_month_to_month_deposit) { 250 }

          before do
            space_params = {
              id: a_space.id,
              description: new_description,
              quantity: new_quantity,
              hour_price: new_hour_price,
              hour_deposit: new_hour_deposit,
              day_price: new_day_price,
              day_deposit: new_day_deposit,
              month_price: new_month_price,
              month_deposit: new_month_deposit,
              month_to_month_price: new_month_to_month_price,
              month_to_month_deposit: new_month_to_month_deposit
            }
            patch :update, id: a_space.id, space: space_params
            a_space.reload
          end

          it 'succeeds' do
            expect(response.status).to eq(302)
          end

          it 'updates the space' do
            expect(a_space.description).to eq(new_description)
            expect(a_space.quantity).to eq(new_quantity)
          end

          it 'updates the prices' do
            expect(a_space.hour_price).to eq(new_hour_price)
            expect(a_space.day_price).to eq(new_day_price)
            expect(a_space.month_price).to eq(new_month_price)
            expect(a_space.month_to_month_price).to eq(new_month_to_month_price)
          end

          it 'updates the deposits' do
            expect(a_space.hour_deposit).to eq(new_hour_deposit)
            expect(a_space.day_deposit).to eq(new_day_deposit)
            expect(a_space.month_deposit).to eq(new_month_deposit)
            expect(a_space.month_to_month_deposit).to eq(new_month_to_month_deposit)
          end

          it 'renders the :edit template' do
            expect(response.redirect_url).to eq(edit_space_url(a_space))
          end

          context 'when lower capacity' do
            context 'when there are bookings' do
              let!(:a_booking) do
                create(:booking, space: a_space,
                                 from: Time.current.at_beginning_of_day,
                                 to: Time.current.advance(minutes: 1))
              end
              before do
                new_capacity = a_space.capacity - 1
                space_params = { id: a_space.id, capacity: new_capacity }

                patch :update, id: a_space.id, space: space_params
                a_space.reload
              end
              it 'fails' do
                expect(response.status).to eq(302)
              end
            end

            context 'where there arent bookings of that space' do
              let!(:a_booking) do
                create(:booking, from: Time.current.at_beginning_of_day,
                                 to: Time.current.advance(minutes: 1))
              end
              before do
                new_capacity = a_space.capacity - 1
                space_params = { id: a_space.id, capacity: new_capacity }

                patch :update, id: a_space.id, space: space_params
                a_space.reload
              end

              it 'succeeds' do
                a_space.bookings.delete_all
                expect(response.status).to eq(302)
              end
            end
          end

          context 'when lower quantity' do
            context 'when it is not bookable' do
              let!(:a_booking) do
                create(:booking, state: Booking.states[:paid], space: a_space,
                                 from: Time.current.at_beginning_of_day,
                                 to: Time.current.at_end_of_day, quantity: a_space.quantity)
              end
              before do
                new_quantity = a_space.quantity - 1
                space_params = { id: a_space.id, quantity: new_quantity }
                patch :update, id: a_space.id, space: space_params
                a_space.reload
              end
              it 'fails' do
                expect(response.status).to eq(302)
              end
            end

            context 'where it is bookable' do
              before do
                new_quantity = a_space.quantity - 1
                space_params = { id: a_space.id, quantity: new_quantity }
                a_space.bookings.delete_all
                patch :update, id: a_space.id, space: space_params
                a_space.reload
              end
              it 'succeeds' do
                expect(response.status).to eq(302)
              end
            end
          end
        end

        context 'when does not have permissions' do
          let(:a_venue) { create(:venue) }
          let(:a_space) { create(:space, capacity: 2, venue: a_venue) }
          let(:new_description) { 'new description' }
          let(:new_quantity) { a_space.quantity + 1 }
          before do
            space_params = { id: a_space.id, description: new_description, quantity: new_quantity }
            patch :update, id: a_space.id, space: space_params
            a_space.reload
          end
          it 'fails' do
            expect(response.status).to eq(403)
          end
        end
      end

      context 'when the space does not exist' do
        before do
          patch :update, id: -1
        end

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end
    end # when user logged in

    context 'when no user is logged in' do
      let!(:a_space) { create(:space) }
      it 'is redirected to login' do
        patch :update, id: a_space.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end # when no user is logged in
  end # UPDATE spaces/:id/update

  describe 'GET venues/:id/new_space' do
    context 'when a user is logged in' do
      before(:each) { sign_in user }

      context 'when the venue belongs to the user' do
        let(:venue) { create(:venue, owner: user) }
        before do
          get :new, id: venue.id
        end

        it 'succeeds' do
          expect(response.status).to eq(200)
        end
      end

      context 'when the venue does not belong to the user' do
        let(:venue) { create(:venue) }

        it 'is forbidden' do
          get :new, id: venue.id
          expect(response.status).to eq(403)
        end
      end

      context 'when the venue does not exist' do
        it 'fails' do
          get :new, id: -1
          expect(response.status).to eq(404)
        end
      end
    end

    context 'when no user is logged in' do
      let!(:venue) { create(:venue) }
      it 'is redirected to login' do
        get :new, id: venue.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end # when no user is logged in
  end # GET venues/:id/new_space

  # search spaces
  describe 'GET index' do
    context 'when a user is logged in' do
      before(:each) { sign_in user }

      it 'suceeds' do
        get :index
        expect(response.status).to eq(200)
      end
    end

    context 'when no user is logged in' do
      it 'suceeds' do
        get :index
        expect(response.status).to eq(200)
      end
    end
  end # GET index

  # search form
  describe 'GET search_mobile' do
    context 'when a user is logged in' do
      before(:each) { sign_in user }

      it 'suceeds' do
        get :search_mobile
        expect(response.status).to eq(200)
      end
    end

    context 'when no user is logged in' do
      it 'suceeds' do
        get :search_mobile
        expect(response.status).to eq(200)
      end
    end
  end # GET search_mobile

  describe 'GET wishlist' do
    context 'when a user is logged in' do
      before(:each) { sign_in user }

      it 'suceeds' do
        get :wishlist
        expect(response.status).to eq(200)
      end
    end

    context 'when no user is logged in' do
      it 'is redirected to login' do
        get :wishlist
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end
  end # GET wishlist

  describe 'DELETE destroy' do
    context 'when a user is logged in' do
      before(:each) { sign_in user }

      context 'when the user owns the space' do
        let(:venue) { create(:venue, owner: user) }
        let(:space) { create(:space, venue: venue) }

        before { delete :destroy, id: space.id }

        it 'suceeds' do
          expect(response.status).to eq(302)
        end

        it 'deletes the space' do
          spaces = Space.where(id: space.id)
          expect(spaces.size).to eq(0)
        end
      end

      context 'when the user does not own the space' do
        let(:space) { create(:space) }

        before { delete :destroy, id: space.id }

        it 'is forbidden' do
          expect(response.status).to eq(403)
        end

        it 'does not delete the space' do
          spaces = Space.where(id: space.id)
          expect(spaces.size).to eq(1)
          expect(spaces.first).to eq(space)
        end
      end

      context 'when the space does not exist' do
        it 'fails' do
          delete :destroy, id: -1
          expect(response.status).to eq(404)
        end
      end
    end # when a user is logged in

    context 'when no user is logged in' do
      let(:space) { create(:space) }

      before { delete :destroy, id: space.id }

      it 'is redirected to login' do
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end

      it 'does not delete the space' do
        spaces = Space.where(id: space.id)
        expect(spaces.size).to eq(1)
        expect(spaces.first).to eq(space)
      end
    end
  end # DELETE destroy
end
