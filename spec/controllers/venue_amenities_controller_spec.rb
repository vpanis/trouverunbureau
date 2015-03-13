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
end
