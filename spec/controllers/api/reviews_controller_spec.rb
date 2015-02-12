require 'rails_helper'

describe Api::V1::ReviewsController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) do
    create(:user)
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

        it 'should retrieve venue reviews ordered by date' do
          get :venue_reviews, id: a_venue.id

          first = JSON.parse(body['reviews'].first.to_json)
          last = JSON.parse(body['reviews'].last.to_json)
          ve_re_first = JSON.parse(VenueReviewSerializer.new(a_ve_re_2).to_json)['venue_review']
          ve_re_last = JSON.parse(VenueReviewSerializer.new(a_ve_re).to_json)['venue_review']
          expect(first).to eql(ve_re_first)
          expect(last).to eql(ve_re_last)
        end

        it 'should paginate venue reviews' do
          page = 2
          amount =  1
          get :venue_reviews, id: a_venue.id, page: page, amount: amount

          expect(body['count']).to eql(2)
          expect(body['items_per_page']).to eql(amount)
          expect(body['current_page']).to eql(page)
          expect(body['reviews'].size).to eql(amount)
        end

        it 'does not paginate venue reviews outside limits' do
          get :venue_reviews, id: a_venue.id, page: 3, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(0)
        end

        it 'does not retrieve other venues reviews' do
          get :venue_reviews, id: a_venue.id
          expect(body['reviews'].any? do |c|
            c.to_json == VenueReviewSerializer.new(a_ve_re_3).to_json
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

    before(:each) do
      @user_logged = FactoryGirl.create(:user)
      request.env['HTTP_ACCEPT'] = 'application/json'
      request.env['USER_EMAIL_AUTH'] = @user_logged.email
      request.env['USER_TOKEN_AUTH'] = @user_logged.authentication_token
    end

    # after(:each) do
    #   sign_out @user_logged
    # end

    context 'when the user exists' do
      let!(:a_user) { create(:user) }
      let!(:a_venue) { create(:venue, :with_spaces, owner: @user_logged) }
      let!(:booking) { create(:booking, owner: a_user, space: a_venue.spaces[0]) }
      it 'succeeds' do
        get :client_reviews, id: a_user.id, type: 'User'
        expect(response.status).to eq(200)
      end

      context 'when the user has reviews' do
        let(:booking_2) { create(:booking, owner: a_user) }
        let(:booking_3) { create(:booking) }

        let!(:a_cl_re) { create(:client_review, booking: booking) }
        let!(:a_cl_re_2) { create(:client_review, booking: booking_2) }
        let!(:a_cl_re_3) { create(:client_review, booking: booking_3) }

        it 'should retrieve client reviews ordered by date' do
          get :client_reviews, id: a_user.id, type: 'User'

          first = JSON.parse(body['reviews'].first.to_json)
          last = JSON.parse(body['reviews'].last.to_json)
          cl_re_first = JSON.parse(ClientReviewSerializer.new(a_cl_re_2).to_json)['client_review']
          cl_re_last = JSON.parse(ClientReviewSerializer.new(a_cl_re).to_json)['client_review']
          expect(first).to eql(cl_re_first)
          expect(last).to eql(cl_re_last)
        end

        it 'should paginate client reviews' do
          page = 2
          amount =  1
          get :client_reviews, id: a_user.id, type: 'User', page: page, amount: amount

          expect(body['count']).to eql(2)
          expect(body['items_per_page']).to eql(amount)
          expect(body['current_page']).to eql(page)
          expect(body['reviews'].size).to eql(amount)
        end

        it 'does not paginate client reviews outside limits' do
          get :client_reviews, id: a_user.id, type: 'User', page: 3, amount: 1
          expect(body['count']).to eql(2)
          expect(body['reviews'].size).to eql(0)
        end

        it 'does not retrieve other client reviews' do
          get :client_reviews, id: a_user.id, type: 'User'
          expect(body['reviews'].any? do |c|
            c.to_json == ClientReviewSerializer.new(a_cl_re_3).to_json
          end).to be false
        end
      end # when the venue has reviews
    end # when the venue exists

    context 'when the user does not exist' do
      before { get :client_reviews, type: 'User', id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end # when the user does not exist
  end # GET users/:id/reviews
end
