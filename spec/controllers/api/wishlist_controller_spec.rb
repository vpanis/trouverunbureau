require 'rails_helper'

describe Api::V1::WishlistController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) do
    create(:user)
  end

  describe 'GET wishlist' do
    context 'when the user is logged in' do
      before(:each) { sign_in user }

      it 'succeeds' do
        get :index
        expect(response.status).to eq(200)
        expect(body['count']).to eql(0)
        expect(body['spaces'].size).to eql(0)
      end

      context 'when the user has favorites' do
        let!(:sp) { create(:space, name: 'a space') }
        let!(:sp2) { create(:space, name: 'the space') }
        let!(:favorite) { create(:users_favorite, user: user, space: sp) }
        let!(:favorite_2) { create(:users_favorite, user: user, space: sp2) }
        let!(:fav_3) { create(:users_favorite) }

        it 'should retrieve user favorites ordered by name' do
          get :index
          first = JSON.parse(body['spaces'].first.to_json)
          last = JSON.parse(body['spaces'].last.to_json)
          f_id =  user.users_favorites.pluck(:space_id)
          f1 = JSON.parse(SpaceSerializer.new(sp, scope: { favorites_ids: f_id })
                                              .to_json)['space']
          f2 = JSON.parse(SpaceSerializer.new(sp2, scope: { favorites_ids: f_id })
                                              .to_json)['space']
          expect(first).to eql(f1)
          expect(last).to eql(f2)
        end

        it 'should paginate user favorites' do
          page = 2
          amount =  1
          get :index, page: page, amount: amount
          expect(body['count']).to eql(2)
          expect(body['items_per_page']).to eql(amount)
          expect(body['current_page']).to eql(page)
          expect(body['spaces'].size).to eql(amount)
        end

        it 'does not paginate user favorites outside limits' do
          get :index, page: 3, amount: 1
          expect(body['count']).to eql(2)
          expect(body['spaces'].size).to eql(0)
        end

        it 'does not retrieve other user favorites' do
          get :index
          f_ids =  user.users_favorites.pluck(:space_id)
          expect(body['spaces'].any? do |c|
            c.to_json == SpaceSerializer.new(fav_3.space, scope: { favorites_ids: f_ids }).to_json
          end).to be false
        end
      end # when the user has favorites
    end # when the user is logged in

    context 'when the user is not logged in' do
      before { get :index }

      it 'fails' do
        expect(response.status).to eq(302)
      end
    end # when the user is not logged in
  end # GET wishlist

  describe 'POST wishlist' do
    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the space exists' do
        let!(:space) { create(:space) }

        context 'when the space is not added to wishlist' do
          before { post :create, id: space.id }

          it 'should return status 204' do
            expect(response.status).to eq(204)
          end

          it 'should create the users favorite' do
            users_favorites = UsersFavorite.where(space: space, user: user)
            expect(users_favorites.size).to be(1)
            expect(UsersFavoriteContext.new(user.id, space.id).wishlisted?).to be true
          end
        end

        context 'when the space is already added to the wishlist' do
          before do
            UsersFavoriteContext.new(user.id, space.id).add_to_wishlist
            post :create, id: space.id
          end

          it 'should return status 412' do
            expect(response.status).to eq(412)
          end

          it 'should not add again to the wishlist' do
            users_favorites = UsersFavorite.where(space: space, user: user)
            expect(users_favorites.size).to be(1)
            expect(UsersFavoriteContext.new(user.id, space.id).wishlisted?).to be true
          end
        end
      end

      context 'when the space does not exist' do
        it 'fails' do
          post :create, space_id: -1
          expect(response.status).to eq(404)
        end
      end # when the space does not exist
    end

    context 'when the user is not logged in' do
      let(:space) { create(:space) }

      it 'fails' do
        post :create, id: space.id
        expect(response.status).to eq(302)
      end
    end # when the user is not logged in

  end # POST users/:id/wishlist

  describe 'DELETE wishlist/id' do
    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the space exists' do
        let!(:space) { create(:space) }

        context 'when the space is not added to wishlist' do
          before { delete :destroy, id: space.id }

          it 'should return status 412' do
            expect(response.status).to eq(412)
          end
        end

        context 'when the space is already added to the wishlist' do
          before do
            UsersFavoriteContext.new(user.id, space.id).add_to_wishlist
            delete :destroy, id: space.id
          end

          it 'should return status 204' do
            expect(response.status).to eq(204)
          end

          it 'should remove the space from the wishlist' do
            users_favorites = UsersFavorite.where(space: space, user: user)
            expect(users_favorites.size).to be(0)
            expect(UsersFavoriteContext.new(user.id, space.id).wishlisted?).to be false
          end
        end
      end

      context 'when the space does not exist' do
        before { delete :destroy, id: -1 }

        it 'fails' do
          expect(response.status).to eq(404)
        end
      end # when the space does not exist
    end # when the user is logged in

    context 'when the user is not logged in' do
      let(:space) { create(:space) }

      it 'fails' do
        delete :destroy, id: space.id
        expect(response.status).to eq(302)
      end
    end # when the user is not logged in
  end # DELETE wishlist/id
end
