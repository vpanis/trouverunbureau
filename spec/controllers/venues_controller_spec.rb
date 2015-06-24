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
      let(:country) { 'FR' }
      let(:name) { 'a name' }
      before { sign_in user }

      context 'name and country_code are present' do
        before do
          @previous_venue = Venue.last
          params = { name: name, country_code: country, force_submit: true }
          post :create, venue: params
          @venue = Venue.last
        end

        it 'succeeds' do
          expect(response.status).to eq(302)
        end

        it 'redirects to edit' do
          expect(response.redirect_url).to eq(edit_venue_url(@venue.id))
        end

        it 'creates a venue with only name, logo and country_code' do
          expect(@venue).not_to eq(@previous_venue)
          expect(@venue.id).to be_present
          expect(@venue.name).to eq(name)
          expect(@venue.country_code).to eq(country)
        end
      end

      context 'name is not present' do
        it 'fails with record invalid' do
          params = { country_code: country, force_submit: true }
          @request.env['HTTP_REFERER'] = 'http://test.com/venues'
          post :create, venue: params
          expect(response.status).to eq(302)
        end
      end

      context 'country_code is not present' do
        it 'fails with record invalid' do
          params = { name: name, force_submit: true }
          @request.env['HTTP_REFERER'] = 'http://test.com/venues'
          post :create, venue: params
          expect(response.status).to eq(302)
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

          it 'is forbidden' do
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

    context 'when no user is logged in' do
      let(:venue) { create(:venue) }

      it 'is redirected to login' do
        get :edit, id: venue.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end # when no user is logged in
  end # GET venues/:id/edit

  describe 'PATCH venues/:id/update' do
    context 'the user is logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'when the venue is owned by the user' do
        let(:venue) do
          create(:venue, owner: user, v_type: Venue.v_types[:hotel],
                         amenities: [Venue::AMENITY_TYPES.last.to_s],
                         professions: [Venue::PROFESSIONS.last.to_s])
        end
        let(:new_country) { 'FR' }
        let(:new_town) { 'new town' }
        let(:new_street) { 'new_street' }
        let(:new_postal_code) { 'aa123' }
        let(:new_email) { 'name@domain.com' }
        let(:new_phone) { '12346789' }
        let(:new_latitude) { '-5.3' }
        let(:new_longitude) { '-3.5' }
        let(:new_name) { 'new name' }
        let(:new_description) { 'new description' }
        let(:new_currency) { 'eur' }
        let(:new_v_type) { 'restaurant' }
        let(:new_amenities) { [Venue::AMENITY_TYPES.first.to_s, Venue::AMENITY_TYPES.second.to_s] }
        let(:new_professions) { [Venue::PROFESSIONS.first.to_s, Venue::PROFESSIONS.second.to_s] }

        before do
          params = { town: new_town, street: new_street, postal_code: new_postal_code,
                     email: new_email, phone: new_phone, latitude: new_latitude,
                     longitude: new_longitude, name: new_name, description: new_description,
                     currency: new_currency, v_type: new_v_type, country_code: new_country }
          patch :update, id: venue.id, venue: params
          venue.reload
        end

        it 'updates the venue' do
          expect(venue.town).to eq(new_town)
          expect(venue.street).to eq(new_street)
          expect(venue.postal_code).to eq(new_postal_code)
          expect(venue.email).to eq(new_email)
          expect(venue.phone).to eq(new_phone)
          expect(venue.latitude).to eq(new_latitude.to_d)
          expect(venue.longitude).to eq(new_longitude.to_d)
          expect(venue.name).to eq(new_name)
          expect(venue.currency).to eq(new_currency)
          expect(venue.v_type).to eq(new_v_type)
          expect(venue.country_code).to eq(new_country)
        end

        it 'does not update unpermited params' do
          expect(venue.description).not_to eq(new_description)
          expect(venue.amenities).not_to eq(new_amenities)
          expect(venue.professions).not_to eq(new_professions)
        end

        it 'succeeds' do
          expect(response.status).to eq(302)
        end

        it 'redirects to details' do
          expect(response.redirect_url).to eq(details_venue_url(venue))
        end

      end # when the venue is owned by the user

      context 'when the venue is owned by someonelse' do
        let(:venue) { create(:venue) }
        it 'is forbidden' do
          patch :update, id: venue.id
          expect(response.status).to eq(403)
        end
      end # when the venue is owned by someonelse

      context 'when the venue does not exist' do
        it 'fails' do
          patch :update, id: -1
          expect(response.status).to eq(404)
        end
      end # when the venue does not exist
    end

    context 'the user is not logged in' do
      context 'when the venue exists' do
        let(:venue) { create(:venue) }

        it 'is redirected to login' do
          patch :update, id: venue.id
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end

      context 'when the venue does not exist' do
        it 'is redirected to login' do
          patch :update, id: -1
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end
    end # when no user is logged in
  end # PATCH venues/:id/update

  describe 'GET venues/:id/photos' do
    context 'when user logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'when the user owns the venue' do
        let!(:venue) { create(:venue, owner: user) }

        it 'succeeds' do
          get :photos, id: venue.id
          expect(response.status).to eq(200)
        end

        it 'assigns the requested venue to @venue' do
          get :photos, id: venue.id
          expect(assigns(:venue)).to eq(venue)
        end

        it 'renders the :photos template' do
          get :photos, id: venue.id
          expect(response).to render_template :photos
        end
      end # when the user owns the venue

      context 'the user does not own the venue' do
        let!(:venue) { create(:venue) }

        it 'is forbidden' do
          get :photos, id: venue.id
          expect(response.status).to eq(403)
        end
      end # the user does not own the venue

      context 'the venue does not exist' do
        before { get :photos, id: -1 }

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when the venue does not exist
    end # when user logged in

    context 'when no user is logged in' do
      let(:venue) { create(:venue) }

      it 'is redirected to login' do
        get :photos, id: venue.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end # when no user is logged in
  end # GET venues/:id/photos

  context 'GET venues' do
    context 'a user is logged in' do
      let!(:owned_venue) { create(:venue, owner: user) }
      let!(:owned_venue2) { create(:venue, owner: user) }
      let!(:others_venue) { create(:venue) }

      before(:each) do
        sign_in user
        get :index
      end

      it 'succeeds' do
        expect(response.status).to eq(200)
      end

      it 'renders the index template' do
        expect(response).to render_template :index
      end

      it 'assigns the owned venues to venues' do
        expect(assigns(:venues).size).to be(2)
        expect(assigns(:venues)).to include(owned_venue)
        expect(assigns(:venues)).to include(owned_venue2)
      end

      it 'does not assigns someoneelses venues to venues' do
        expect(assigns(:venues)).not_to include(others_venue)
      end
    end

    context 'no user is logged in' do
      it 'is redirected to login' do
        get :index
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end
  end
end
