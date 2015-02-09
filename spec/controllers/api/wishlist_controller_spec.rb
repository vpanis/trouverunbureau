require 'rails_helper'

describe Api::V1::WishlistController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) do
    create(:user)
  end

  before do

  end

  describe 'GET users/:id/wishlist' do

    context 'when the user exists' do
      let!(:a_user) { create(:user) }

      it 'succeeds' do
        get :wishlist, id: a_user.id
        expect(response.status).to eq(200)
      end

      context 'when the user has favorites' do
        let!(:space) { create(:space, name: 'a space') }
        let!(:space_2) { create(:space, name: 'the space') }
        let!(:favorite) { create(:users_favorite, user: a_user, space: space) }
        let!(:favorite_2) { create(:users_favorite, user: a_user, space: space_2) }
        let!(:favorite_3) { create(:users_favorite) }

        it 'should retrieve user favorites ordered by name' do
          get :wishlist, id: a_user.id
          first = JSON.parse(body['spaces'].first.to_json)
          last = JSON.parse(body['spaces'].last.to_json)
          fav_first = JSON.parse(UserFavoriteSerializer.new(favorite).to_json)['user_favorite']
          fav_last = JSON.parse(UserFavoriteSerializer.new(favorite_2).to_json)['user_favorite']
          expect(first).to eql(fav_first)
          expect(last).to eql(fav_last)
        end

        it 'should paginate user favorites' do
          page = 2
          amount =  1
          get :wishlist, id: a_user.id, page: page, amount: amount
          expect(body['count']).to eql(2)
          expect(body['items_per_page']).to eql(amount)
          expect(body['current_page']).to eql(page)
          expect(body['spaces'].size).to eql(amount)
        end

        it 'does not paginate user favorites outside limits' do
          get :wishlist, id: a_user.id, page: 3, amount: 1
          expect(body['count']).to eql(2)
          expect(body['spaces'].size).to eql(0)
        end

        it 'does not retrieve other user favorites' do
          get :wishlist, id: a_user.id
          expect(body['spaces'].any? do |c|
            c.to_json == UserFavoriteSerializer.new(favorite_3).to_json
          end).to be false
        end
      end # when the user has favorites
    end # when the user exists

    context 'when the user does not exist' do
      before { get :wishlist, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end # when the user does not exist
  end # GET users/:id/wishlist
end
