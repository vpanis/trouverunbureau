require 'rails_helper'

describe UsersController do

  describe 'GET show' do
    context 'when no user is logged in' do
      context 'when the user exists' do
        let(:user) { create(:user) }

        before { get :show, id: user.id }

        it 'assigns @user' do
          expect(assigns(:user)).to eq(user)
        end

        it 'sets @can_edit' do
          expect(assigns(:can_edit)).to eq(false)
        end

        it 'sets @can_view_reviews' do
          expect(assigns(:can_view_reviews)).to eq(false)
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end # when the user exists

      context 'when the user does not exist' do
        before { get :show, id: -1 }

        it 'fails' do
          expect(response.status).to be(404)
        end
      end # when the user does not exist
    end # when no user is logged in

    context 'when a user is logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      context 'when viewing another user\'s profile' do
        let(:user) { create(:user) }
        before { get :show, id: user.id }
        it 'assigns @user' do
          expect(assigns(:user)).to eq(user)
        end

        it 'sets @can_edit' do
          expect(assigns(:can_edit)).to eq(false)
        end

        it 'sets @can_view_reviews' do
          expect(assigns(:can_view_reviews)).to eq(false)
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end # when viewing another users profile

      context 'when viewing his own profile' do
        before { get :show, id: @user_logged.id }
        it 'assigns @user' do
          expect(assigns(:user)).to eq(@user_logged)
        end

        it 'sets @can_edit' do
          expect(assigns(:can_edit)).to eq(true)
        end

        it 'sets @can_view_reviews' do
          expect(assigns(:can_view_reviews)).to eq(true)
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end # when viewing his own profile

      context 'when viewing the profile of a former client' do
        let(:user) { create(:user) }
        let(:venue) { create(:venue, owner: @user_logged) }
        let(:space) { create(:space, venue: venue) }
        let!(:booking) do
          create(:booking, owner: user, space: space, state: Booking.states[:paid])
        end
        before { get :show, id: user.id }
        it 'assigns @user' do
          expect(assigns(:user)).to eq(user)
        end

        it 'sets @can_edit' do
          expect(assigns(:can_edit)).to eq(false)
        end

        it 'sets @can_view_reviews' do
          expect(assigns(:can_view_reviews)).to eq(true)
        end

        it 'renders the show template' do
          expect(response).to render_template('show')
        end
      end # when viewing the profile of a former client
    end # when a user is logged in
  end # GET show

  describe 'GET edit' do
    context 'when no user is logged in' do
      context 'when the user exists' do
        let(:user) { create(:user) }

        before { get :edit, id: user.id }

        it 'is redirected to login' do
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end # when the user exists

      context 'when the user does not exist' do
        before { get :edit, id: -1 }

        it 'is redirected to login' do
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end # when the user does not exist
    end # when no user is logged in

    context 'when a user is logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      context 'when editing another user\'s profile' do
        let(:user) { create(:user) }
        before { get :edit, id: user.id }

        it 'is forbidden' do
          expect(response.status).to be(403)
        end
      end # when editing another users profile

      context 'when editing his own profile' do
        before { get :edit, id: @user_logged.id }
        it 'assigns @user' do
          expect(assigns(:user)).to eq(@user_logged)
        end

        it 'assings @gender_options' do
          expect(assigns(:gender_options)).to be_present
        end

        it 'assings @profession_options' do
          expect(assigns(:profession_options)).to be_present
        end

        it 'assings @language_options' do
          expect(assigns(:language_options)).to be_present
        end

        it 'renders the edit template' do
          expect(response).to render_template('edit')
        end
      end # when editing his own profile
    end # when a user is logged in
  end # GET edit

  describe 'PATCH update' do
    context 'when no user is logged in' do
      context 'when the user exists' do
        let(:user) { create(:user) }

        before { patch :update, id: user.id }

        it 'is redirected to login' do
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end # when the user exists

      context 'when the user does not exist' do
        before { patch :update, id: -1 }

        it 'is redirected to login' do
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end # when the user does not exist
    end # when no user is logged in

    context 'when a user is logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      context 'when updating another user\'s profile' do
        let(:user) { create(:user) }
        before { patch :update, id: user.id }

        it 'is forbidden' do
          expect(response.status).to be(403)
        end
      end # when editing another users profile

      context 'when updating his own profile' do
        let(:new_first_name) { 'new_first_name' }
        let(:new_last_name) { 'new_last_name' }
        let(:new_email) { 'new@example.com' }
        let(:new_phone) { '1111111' }
        let(:new_language) { User::LANGUAGES.sample.to_s }
        let(:new_date_of_birth) { '14-07-1982' }
        let(:new_gender) { User::GENDERS.sample.to_s }
        let(:new_profession) { Venue::PROFESSIONS.last.to_s }
        let(:new_company_name) { 'new_company_name' }
        let(:new_emergency_phone) { '2222222' }
        before do
          params = { id: @user_logged.id, first_name: new_first_name, last_name: new_last_name,
                         email: new_email, phone: new_phone, language: new_language,
                         date_of_birth: new_date_of_birth, gender: new_gender,
                         profession: new_profession, company_name: new_company_name,
                         emergency_phone: new_emergency_phone }
          patch :update, id: @user_logged.id, user: params
        end

        it 'updates the user' do
          @user_logged.reload
          expect(@user_logged.first_name).to eq(new_first_name)
          expect(@user_logged.last_name).to eq(new_last_name)
          expect(@user_logged.email).to eq(new_email)
          expect(@user_logged.phone).to eq(new_phone)
          expect(@user_logged.language).to eq(new_language)
          expect(@user_logged.date_of_birth).to eq(new_date_of_birth)
          expect(@user_logged.gender).to eq(new_gender)
          expect(@user_logged.profession).to eq(new_profession)
          expect(@user_logged.company_name).to eq(new_company_name)
          expect(@user_logged.emergency_phone).to eq(new_emergency_phone)
        end

        it 'succeeds' do
          expect(response.status).to eq(302)
        end
      end # when viewing his own profile
    end # when a user is logged in
  end # GET edit
end
