require 'rails_helper'

describe VenueAmenitiesController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) { create(:user) }

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
          it 'is forbidden' do
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

  context 'PATCH venues/:id/amenities' do
    context 'a user is logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'the venue belongs to the user' do
        let!(:venue) do
          create(:venue, owner: user,
                         amenities: [Venue::AMENITY_TYPES[3].to_s, Venue::AMENITY_TYPES[4].to_s])
        end
        let(:new_amenities) do
          [Venue::AMENITY_TYPES[2].to_s, Venue::AMENITY_TYPES[3].to_s,
           Venue::AMENITY_TYPES[5].to_s]
        end

        before do
          params = { id: venue.id, amenities: new_amenities }
          patch :save_amenities, id: venue.id, venue: params
          venue.reload
        end

        it 'succeeds' do
          expect(response.status).to eq(302)
        end

        it 'updates amenities' do
          expect(venue.amenities).to eq(new_amenities)
        end

        it 'renders the :photos template' do
          expect(response.redirect_url).to eq(photos_venue_url(venue))
        end
      end

      context 'the venue does not belong to the user' do
        let!(:venue) { create(:venue) }
        it 'is forbidden' do
          patch :save_amenities, id: venue.id
          expect(response.status).to eq(403)
        end
      end

      context 'the venue does not exist' do
        before { patch :save_amenities, id: -1 }

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end
    end # a user is logged in

    context 'no user is logged in' do
      context 'when the venue exists' do
        let!(:venue) { create(:venue) }
        before { patch :save_amenities, id: venue.id }

        it 'fails' do
          expect(response.status).to eq(302)
        end

        it 'redirects to signin' do
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end

      context 'when the venue does not exists' do
        before { patch :save_amenities, id: -1 }

        it 'fails' do
          expect(response.status).to eq(302)
        end

        it 'redirects to signin' do
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end
    end # when the user is not logged in
  end
end
