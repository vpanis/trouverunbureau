require 'rails_helper'

describe VenuesController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) { create(:user) }

  describe 'GET venues/new' do
    context 'when the user is logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      it 'succeeds' do
        get :new
        expect(response.status).to eq(200)
      end
    end # when the user is logged in

    context 'when no user is logged in' do
      it 'is redirected to login' do
        get :new
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end # when no user is logged in
  end # GET venues/new

  describe 'POST venues/create' do
    context 'the user is logged in' do
      let(:country) { create(:country) }
      let(:name) { 'a name' }
      before { sign_in user }

      context 'name and country are present' do
        before do
          @previous_venue = Venue.last
          params = { name: name, country_id: country.id, force_submit: true }
          post :create, venue: params
          @venue = Venue.last
        end

        it 'succeeds' do
          expect(response.status).to eq(302)
        end

        it 'redirects to edit' do
          expect(response.redirect_url).to eq(edit_venue_url(@venue.id))
        end

        it 'creates a venue with only name, logo and country' do
          expect(@venue).not_to eq(@previous_venue)
          expect(@venue.id).to be_present
          expect(@venue.name).to eq(name)
          expect(@venue.country).to eq(country)
        end
      end

      context 'name is not present' do
        it 'fails with record invalid' do
          params = { country_id: country.id, force_submit: true }
          expect { post :create, venue: params }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'country is not present' do
        it 'fails with record invalid' do
          params = { name: name, force_submit: true }
          expect { post :create, venue: params }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end # when the user is logged in

    context 'when no user is logged in' do
      it 'is redirected to login' do
        post :create
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end # when no user is logged in
  end # POST venues/create

  describe 'GET venues/:id/edit' do
    context 'when user logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'when the venue exists' do
        context 'when has permissions' do
          let!(:venue) { create(:venue, owner: user) }

          it 'succeeds' do
            get :edit, id: venue.id
            expect(response.status).to eq(200)
          end

          it 'assigns the requested venue to @venue' do
            get :edit, id: venue.id
            expect(assigns(:venue)).to eq(venue)
          end

          it 'renders the :edit template' do
            get :edit, id: venue.id
            expect(response).to render_template :edit
          end
        end # when has permissions

        context ' when has not permissions' do
          let!(:venue) { create(:venue) }

          it 'succeeds' do
            get :edit, id: venue.id
            expect(response.status).to eq(403)
          end
        end # when has not permissions
      end # when the venue exists

      context 'when the venue does not exist' do
        before { get :edit, id: -1 }

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when the venue does not exist
    end # when user logged in
  end # GET venues/:id/edit

  describe 'PATCH venues/:id/update' do

    context 'when user is logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'when the venue exists' do
        context 'when the user owns the venue' do
          let(:a_venue) { create(:venue, owner: user) }
          let(:venue_hour) do
            create(:venue_hour, weekday: 1, from: 1600, to: 1700,  venue_id: a_venue.id)
          end
          let(:a_space) { create(:space, capacity: 2, venue: a_venue) }
          let(:new_description) { 'new description' }
          let(:day_hours_attributes) do
            { '0' => { from: '1500', to: '1700', weekday: 0 },
              '1' => { id: venue_hour.id, from: '', to: '', weekday: '', _destroy: true },
              '2' => { from: '1600', to: '1700', weekday: 2 },
              '3' => { from: '', to: '', weekday: '', _destroy: true },
              '4' => { from: '', to: '', weekday: '', _destroy: true },
              '5' => { from: '', to: '', weekday: '', _destroy: true },
              '6' => { from: '', to: '', weekday: '', _destroy: true } }
          end

          before do
            venue_params = { id: a_venue.id, description: new_description,
                             day_hours_attributes: day_hours_attributes }
            patch :update, id: a_venue.id, venue: venue_params
            a_venue.reload
          end

          it 'succeeds' do
            expect(response.status).to eq(302)
          end

          it 'updates normal venue attributes' do
            expect(a_venue.description).to eq(new_description)
          end

          it 'updates venue_hours' do
            expect(a_venue.day_hours.count).to eq(2)
            day_hour_0 = a_venue.day_hours.where { weekday == 0 }.first
            day_hour_2 = a_venue.day_hours.where { weekday == 2 }.first
            expect(day_hour_0.from).to eq(day_hours_attributes['0'][:from].to_i)
            expect(day_hour_0.to).to eq(day_hours_attributes['0'][:to].to_i)
            expect(day_hour_2.from).to eq(day_hours_attributes['2'][:from].to_i)
            expect(day_hour_2.to).to eq(day_hours_attributes['2'][:to].to_i)
          end

          it 'renders the :edit template' do
            expect(response.redirect_url).to eq(details_venue_url(a_venue))
          end

          context 'when wrong venue_hours parameters' do
            before do
              day_hours_attributes = { '0' => { from: '1650', to: '1700', weekday: 0 },
                                       '1' => { from: '', to: '', weekday: '', _destroy: true },
                                       '2' => { from: '', to: '', weekday: 2, _destroy: true },
                                       '3' => { from: '', to: '', weekday: '', _destroy: true },
                                       '4' => { from: '', to: '', weekday: '', _destroy: true },
                                       '5' => { from: '', to: '', weekday: '', _destroy: true },
                                       '6' => { from: '', to: '', weekday: '', _destroy: true } }
              venue_params = { id: a_venue.id, day_hours_attributes: day_hours_attributes }
              patch :update, id: a_venue.id, venue: venue_params
              a_venue.reload
            end

            it 'fails' do
              expect(response.status).to eq(412)
            end
          end # when wrong venue_hours parameters

          context 'when reducing venue_hours' do
            context 'when there are bookings' do
              let!(:a_booking) do
                create(:booking, space: a_space,
                                 from: Time.zone.now.advance(minutes: 2),
                                 to: Time.zone.now.advance(minutes: 10), state: :paid)
              end

              before do
                day_hours_attributes = { '0' => { from: '1600', to: '1700', weekday: 0 },
                                         '1' => { from: '', to: '', weekday: '', _destroy: true },
                                         '2' => { from: '', to: '', weekday: 2, _destroy: true },
                                         '3' => { from: '', to: '', weekday: '', _destroy: true },
                                         '4' => { from: '', to: '', weekday: '', _destroy: true },
                                         '5' => { from: '', to: '', weekday: '', _destroy: true },
                                         '6' => { from: '', to: '', weekday: '', _destroy: true } }
                venue_params = { id: a_venue.id, day_hours_attributes: day_hours_attributes }
                patch :update, id: a_venue.id, venue: venue_params
                a_venue.reload
              end

              it 'fails' do
                expect(response.status).to eq(412)
              end
            end # when there are bookings

            context 'where there aren\'t bookings of venue\' spaces' do
              before do
                day_hour_0 = a_venue.day_hours.where { weekday == 0 }.first
                day_hour_2 = a_venue.day_hours.where { weekday == 2 }.first
                day_hours_attributes = { '0' => { id: day_hour_0.id, from: '1600', to: '1700',
                                                  weekday: 0 },
                                         '1' => { from: '', to: '', weekday: '', _destroy: true },
                                         '2' => { id: day_hour_2.id, from: '', to: '', weekday: 2,
                                                  _destroy: true },
                                         '3' => { from: '', to: '', weekday: '', _destroy: true },
                                         '4' => { from: '', to: '', weekday: '', _destroy: true },
                                         '5' => { from: '', to: '', weekday: '', _destroy: true },
                                         '6' => { from: '', to: '', weekday: '', _destroy: true } }
                venue_params = { id: a_venue.id, day_hours_attributes: day_hours_attributes }
                patch :update, id: a_venue.id, venue: venue_params
                a_venue.reload
              end

              it 'succeeds' do
                expect(response.status).to eq(302)
                expect(a_venue.day_hours.count).to eq(1)
              end
            end # where there aren't bookings of venue' spaces
          end # when reducing venue_hours
        end # when the user owns the venue

        context 'when the user does not own the venue' do
          let(:a_venue) { create(:venue) }
          let(:new_description) { 'new description' }

          before do
            venue_params = { id: a_venue.id, description: new_description }
            patch :update, id: a_venue.id, venue: venue_params
            a_venue.reload
          end

          it 'fails' do
            expect(response.status).to eq(403)
          end
        end # when the user does not own the venue
      end # when the venue exists

      context 'when the venue does not exist' do
        before do
          patch :update, id: -1
        end

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when the venue does not exist
    end # when user is logged in

    context 'when the user is not logged in' do
      context 'when the venue exists' do
        let!(:venue) { create(:venue) }
        before { patch :update, id: venue.id }

        it 'fails' do
          expect(response.status).to eq(302)
        end

        it 'redirects to signin' do
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end

      context 'when the venue does not exist' do
        before { patch :update, id: -1 }

        it 'fails' do
          expect(response.status).to eq(302)
        end

        it 'redirects to signin' do
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end
    end # when the user is not logged in
  end # PATCH venues/:id/update

  describe 'GET venues/:id/amenities' do
    context 'when user is logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'when the venue exists' do
        context 'when user owns the venue' do
          let!(:venue) { create(:venue, owner: user) }

          it 'succeeds' do
            get :amenities, id: venue.id
            expect(response.status).to eq(200)
          end

          it 'assigns the requested venue to @venue' do
            get :amenities, id: venue.id
            expect(assigns(:venue)).to eq(venue)
          end

          it 'renders the :amenities template' do
            get :amenities, id: venue.id
            expect(response).to render_template :amenities
          end
        end # when the user owns the venue

        context 'when the user doesnt own the venue' do
          let!(:venue) { create(:venue) }
          it 'fails' do
            get :amenities, id: venue.id
            expect(response.status).to eq(403)
          end
        end # when the user does not own the venue
      end # when the venue exists

      context 'when the venue does not exist' do
        before { get :amenities, id: -1 }

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when the venue does not exist
    end # when user logged in

    context 'when the user is not logged in' do
      context 'when the venue exists' do
        let!(:venue) { create(:venue) }
        before { get :amenities, id: venue.id }

        it 'fails' do
          expect(response.status).to eq(302)
        end

        it 'redirects to signin' do
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end

      context 'when the venue does not exists' do
        before { get :amenities, id: -1 }

        it 'fails' do
          expect(response.status).to eq(302)
        end

        it 'redirects to signin' do
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end
    end # when the user is not logged in
  end  # GET venues/:id/amenities
end
