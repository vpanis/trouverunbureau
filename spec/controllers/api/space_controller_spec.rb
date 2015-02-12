require 'rails_helper'

describe Api::V1::SpaceController do

  let(:body) { JSON.parse(response.body) if response.body.present? }

  before do

  end

  describe 'GET spaces' do

    context 'when a space exists' do
      let!(:venue) { create(:venue, name: 'a venue') }
      let!(:venue_2) { create(:venue, name: 'the venue') }

      let!(:space) { create(:space, venue: venue) }
      let!(:space_2) { create(:space, venue: venue_2) }

      it 'should retrieve spaces ordered by name' do
        get :list

        first = JSON.parse(body['spaces'].first.to_json)
        last = JSON.parse(body['spaces'].last.to_json)
        space_first = JSON.parse(SpaceSerializer.new(space).to_json)['space']
        space_last = JSON.parse(SpaceSerializer.new(space_2).to_json)['space']
        expect(first).to eql(space_first)
        expect(last).to eql(space_last)
      end

      it 'should paginate spaces' do
        page = 2
        amount =  1
        get :list, page: page, amount: amount

        expect(body['count']).to eql(2)
        expect(body['items_per_page']).to eql(amount)
        expect(body['current_page']).to eql(page)
        expect(body['spaces'].size).to eql(amount)
      end

      it 'does not paginate spaces outside limits' do
        get :list, page: 3, amount: 1
        expect(body['count']).to eql(2)
        expect(body['spaces'].size).to eql(0)
      end

    end # when a space exists

    context 'when no spaces exist' do
      before { get :list }
      it 'does not retrieve any space' do

        expect(response.status).to eq(200)
        expect(body['count']).to eql(0)
        expect(body).to include('items_per_page')
        expect(body).to include('current_page')
        expect(body['spaces'].size).to eql(0)
      end
    end # when no spaces exist
  end # GET spaces

end
