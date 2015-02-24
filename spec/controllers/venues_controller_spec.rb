require 'rails_helper'

describe VenuesController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) do
    create(:user)
  end

  describe 'GET venues/:id/edit' do
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
          let!(:a_venue) { create(:venue, owner: @user_logged) }
          let(:a_space) { create(:space, venue: a_venue) }

          it 'succeeds' do
            get :edit, id: a_venue.id
            expect(response.status).to eq(200)
          end
          it 'assigns the requested venue to @venue' do
            get :edit, id: a_venue.id
            expect(assigns(:venue)).to eq(a_venue)
          end

          it 'renders the :edit template' do
            get :edit, id: a_venue.id
            expect(response).to render_template :edit
          end
        end # when has permissions

        context ' when has not permissions' do
          let!(:a_venue) { create(:venue) }
          it 'succeeds' do
            get :edit, id: a_venue.id
            expect(response.status).to eq(403)
          end
        end # when has not permissions
      end # when the space exists

      context 'when the venue does not exist' do
        before { get :edit, id: -1 }

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when the venue does not exist
    end # when user logged in
  end # GET venues/:id/edit

  describe 'UPDATE venues/:id/update' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end
      context 'when the venue exists' do
        context 'when has permissions' do
          let(:a_venue) { create(:venue, owner: @user_logged) }
          let(:a_space) { create(:space, capacity: 2, venue: a_venue) }
          let(:new_description) { 'new description' }
          let(:day_from) { ['1630', '', '', '', '', '', ''] }
          let(:day_to) { ['1700', '', '', '', '', '', ''] }
          before do
            venue_params = { id: a_venue.id, description: new_description }
            patch :update, id: a_venue.id, venue: venue_params, day_from: day_from, day_to: day_to
            a_venue.reload
          end

          it 'succeeds' do
            expect(response.status).to eq(302)
          end

          it 'updates the venue' do
            expect(a_venue.description).to eq(new_description)
            expect(a_venue.day_hours.first.from).to eq(day_from[0].to_i)
            expect(a_venue.day_hours.first.to).to eq(day_to[0].to_i)
          end

          it 'renders the :edit template' do
            expect(response.redirect_url).to eq(edit_venue_url(a_venue))
          end

        end

        context 'when does not have permissions' do
          let(:a_venue) { create(:venue) }
          let(:a_space) { create(:space, capacity: 2, venue: a_venue) }
          let(:new_description) { 'new description' }
          before do
            venue_params = { id: a_venue.id, description: new_description }
            patch :update, id: a_venue.id, venue: venue_params
            a_venue.reload
          end
          it 'fails' do
            expect(response.status).to eq(403)
          end
        end
      end

      context 'when the venue does not exist' do
        before do
          patch :update, id: -1
        end

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end
    end # when user logged in

  end # UPDATE venues/:id/update
end
