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
        get :venue_reviews, id: a_venue.id
        expect(response.status).to eq(200)
      end

      context 'when the venue has reviews' do
        let(:space) { create(:space, venue: a_venue) }
        let(:booking) { create(:booking, space: space) }
        let(:booking_2) { create(:booking, space: space) }

        let!(:a_ve_re) { create(:venue_review, booking: booking) }
        let!(:a_ve_re_2) { create(:venue_review, booking: booking_2) }
        let!(:a_ve_re_3) { create(:venue_review) }

        it 'should return an array of venue reviews' do
          get :venue_reviews, id: a_venue.id
          expect(body['count']).to eql(2)
          expect(body).to include('items_per_page')
          expect(body).to include('current_page')
          expect(body['reviews'].any? do |c|
            JSON.parse(c.to_json) == JSON.parse(ReviewSerializer.new(a_ve_re).to_json)['review']
          end).to be true
        end

        it 'should retrieve venue reviews ordered by date' do
          get :venue_reviews, id: a_venue.id
          first = JSON.parse(body['reviews'].first.to_json)
          expect(first).to eql(JSON.parse(ReviewSerializer.new(a_ve_re_2).to_json)['review'])
        end

        it 'should paginate venue reviews' do
          get :venue_reviews, id: a_venue.id, page: 1, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(1)
          get :venue_reviews, id: a_venue.id, page: 2, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(1)
        end

        it 'does not paginate venue reviews outside limits' do
          get :venue_reviews, id: a_venue.id, page: 3, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(0)
        end

        it 'does not retrieve other venues reviews' do
          get :venue_reviews, id: a_venue.id
          expect(body['reviews'].any? do |c|
            c.to_json == ReviewSerializer.new(a_ve_re_3).to_json
          end).to be false
        end
      end # when the venue has reviews
    end # when the venue exists

    context 'when the venue does not exist' do
      before { get :venue_reviews, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end # when the venue does not exist
  end # GET venues/:id/reviews

  describe 'GET users/:id/reviews' do

    context 'when the user exists' do
      let!(:a_user) { create(:user) }
      it 'succeeds' do
        get :client_reviews, id: a_user.id
        expect(response.status).to eq(200)
      end

      context 'when the user has reviews' do
        let(:booking) { create(:booking, owner: a_user) }
        let(:booking_2) { create(:booking, owner: a_user) }
        let(:booking_3) { create(:booking) }

        let!(:a_cl_re) { create(:client_review, booking: booking) }
        let!(:a_cl_re_2) { create(:client_review, booking: booking_2) }
        let!(:a_cl_re_3) { create(:client_review, booking: booking_3) }

        it 'should return an array of client reviews' do
          get :client_reviews, id: a_user.id
          expect(body['count']).to eql(2)
          expect(body).to include('items_per_page')
          expect(body).to include('current_page')
          expect(body['reviews'].any? do |c|
            cl_review = JSON.parse(ClientReviewSerializer.new(a_cl_re).to_json)['client_review']
            JSON.parse(c.to_json) == cl_review
          end).to be true
        end

        it 'should retrieve client reviews ordered by date' do
          get :client_reviews, id: a_user.id
          first = JSON.parse(body['reviews'].first.to_json)
          cl_review = JSON.parse(ClientReviewSerializer.new(a_cl_re_2).to_json)['client_review']
          expect(first).to eql(cl_review)
        end

        it 'should paginate client reviews' do
          get :client_reviews, id: a_user.id, page: 1, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(1)
          get :client_reviews, id: a_user.id, page: 2, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(1)
        end

        it 'does not paginate client reviews outside limits' do
          get :client_reviews, id: a_user.id, page: 3, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(0)
        end

        it 'does not retrieve other client reviews' do
          get :client_reviews, id: a_user.id
          expect(body['reviews'].any? do |c|
            c.to_json == ReviewSerializer.new(a_cl_re_3).to_json
          end).to be false
        end
      end # when the venue has reviews
    end # when the venue exists

    context 'when the user does not exist' do
      before { get :client_reviews, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end # when the user does not exist
  end # GET users/:id/reviews
end
