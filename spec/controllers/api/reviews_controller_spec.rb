require 'rails_helper'

describe Api::ReviewsController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) do
    create(:user)
  end

  before do

  end

  describe 'GET venues/:id/reviews' do

    context 'when the venue exists' do
      let!(:a_venue) { create(:venue) }
      let!(:a_booking) { create(:booking) }
      let!(:a_venue_review) { create(:venue_review) }
      it 'succeeds' do
        get :reviews, id: a_venue.id
        expect(response.status).to eq(200)
      end

      context 'when the venue has reviews' do
        let!(:followed_user) { create(:venue) }

        before do
        end

        it 'should be a review in the result' do
          expect(body['reviews']['id']).to eql(a_venue_review.id)
          expect(body.first['reviews']['message']).to eql(a_venue_review.message)
          expect(body.first['reviews']['user']['name']).to eql(:a_booking.owner.first_name +
            :a_booking.owner.last_name)
          expect(body.first['reviews']['user']['avatar']).to eql(:a_booking.owner.avatar.url)
          expect(body.first['reviews']['date']).to eql(a_venue_review.created_at)
        end
      end # when the user has followed a user
    end # when the venue exists

    context 'when the venue does not exist' do
      before { get :reviews, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end # when the venue does not exist
  end # GET venues/:id/reviews
end
