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
        let!(:followed_user) { create(:user) }

        before do
          FollowshipContext.new(a_user, followed_user).follow
          get :user_feed, id: a_user.id
        end

        it 'should be a followship item in the feed' do
          expect(body.first['type']).to eql('followship')
          expect(body.first['source']['id']).to eql(a_user.id)
          expect(body.first['source']['name']).to eql(a_user.name)
          expect(body.first['target']['id']).to eql(followed_user.id)
          expect(body.first['target']['name']).to eql(followed_user.name)
          expect(body.first['short_description']).to eql(nil)
          expect(body.first['avatar']).to eql(a_user.avatar.url)
        end
      end # when the user has followed a user

      context 'when the user has attended an event' do
        let(:event) { create(:night_club_event) }

        before do
          AttendeeContext.new(a_user, event).attend
          get :user_feed, id: a_user.id
        end

        it 'should be an attending item in the feed' do
          expect(body.first['type']).to eql('attending')
          expect(body.first['source']['id']).to eql(a_user.id)
          expect(body.first['source']['name']).to eql(a_user.name)
          expect(body.first['target']['id']).to eql(event.id)
          expect(body.first['target']['name']).to eql(event.title)
          expect(body.first['short_description']).to eql(nil)
          expect(body.first['avatar']).to eql(a_user.avatar.url)
        end
      end # when the user has attended an event
    end # when the user exists

    context 'when the venue does not exist' do
      before { get :reviews, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end # when the venue does not exist
  end # GET venues/:id/reviews


end
