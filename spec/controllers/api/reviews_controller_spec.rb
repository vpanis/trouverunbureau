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
      it 'succeeds' do
        get :reviews, id: a_venue.id
        expect(response.status).to eq(200)
      end

      context 'when the venue has reviews' do
        let!(:a_ve_re) { create(:venue_review) }
        it 'should be a review in the result' do
          get :reviews, id: a_ve_re.booking.space.venue_id
          expect(body['count']).to eql(1)
          expect(body).to include("items_per_page")
          expect(body).to include("current_page")
          expect(body['reviews'].first['id']).to eql(a_ve_re.id)
          expect(body['reviews'].first['message']).to eql(a_ve_re.message)
          expect(body['reviews'].first['date']).to eql(a_ve_re.created_at.strftime('%d/%m/%Y'))
          expect(body['reviews'].first['owner']['avatar']).to eql(a_ve_re.booking.owner.avatar.url)
          expect(body['reviews'].first['owner']['name']).to eql(
            [a_ve_re.booking.owner.first_name, a_ve_re.booking.owner.last_name].join(' '))
        end
      end # when the venue has reviews
    end # when the venue exists

    context 'when the venue does not exist' do
      before { get :reviews, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end # when the venue does not exist
  end # GET venues/:id/reviews
end
