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
          it 'succeeds' do
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
          before do
            space_params = { id: a_space.id, description: new_description, quantity: new_quantity }
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

          it 'renders the :edit template' do
            expect(response.redirect_url).to eq(edit_space_url(a_space))
          end

          context 'when lower capacity' do
            context 'when there are bookings' do
              let!(:a_booking) do
                create(:booking, space: a_space,
                                 from: Time.zone.now.at_beginning_of_day,
                                 to: Time.zone.now.advance(minutes: 1))
              end
              before do
                new_capacity = a_space.capacity - 1
                space_params = { id: a_space.id, capacity: new_capacity }

                patch :update, id: a_space.id, space: space_params
                a_space.reload
              end
              it 'fails' do
                expect(response.status).to eq(412)
              end
            end

            context 'where there arent bookings of that space' do
              let!(:a_booking) do
                create(:booking, from: Time.zone.now.at_beginning_of_day,
                                 to: Time.zone.now.advance(minutes: 1))
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
                                 from: Time.zone.now.at_beginning_of_day,
                                 to: Time.zone.now.at_end_of_day, quantity: a_space.quantity)
              end
              before do
                new_quantity = a_space.quantity - 1
                space_params = { id: a_space.id, quantity: new_quantity }
                patch :update, id: a_space.id, space: space_params
                a_space.reload
              end
              it 'fails' do
                expect(response.status).to eq(412)
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

  end # UPDATE spaces/:id/update
end
