require 'rails_helper'

describe Api::V1::OrganizationUsersController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }

  before(:each) do
    @user_logged = FactoryGirl.create(:user)
    sign_in @user_logged
  end

  after(:each) do
    sign_out @user_logged
  end

  describe 'GET organization/:id/organization_users' do
    context 'when the organization exists' do
      let!(:a_organization) { create(:organization) }
      it 'succeeds' do
        get :index, organization_id: a_organization.id
        expect(response.status).to eq(200)
      end

      context 'when the organization has organization users' do
        let(:org_user_1) do
          create(:organization_user, user: user, organization: a_organization)
        end
        let(:org_user_2) do
          create(:organization_user, user: user2, organization: a_organization)
        end
        it 'should retrieve the organization members' do
          get :index, organization_id: a_organization.id
          response_count = body.count
          count = a_organization.organization_users.count
          expect(response_count).to eq(count)
        end
      end
    end
  end

  describe 'POST organization/:id/organization_users' do
    before(:each) do
      @organization = FactoryGirl.create(:organization)
      @organization2 = FactoryGirl.create(:organization)
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:organization_user, user: @user_logged, organization: @organization)
    end

    context 'when the email is valid' do
      it 'should add the user' do
        post :create, organization_id: @organization.id, email: user.email
        expect(response.status).to eq(201)
      end
    end

    context 'when the email is invalid' do
      it 'should not add the user' do
        post :create, organization_id: @organization.id, email: 'notused@email.com'
        expect(response.status).to eq(404)
      end
    end

    context 'when the current respresented is not available to add a member' do
      it 'should return forbidden' do
        post :create, organization_id: @organization2.id, email: user.email
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'DELETE organization/:id/organization_users/:id' do
    before(:each) do
      @organization = FactoryGirl.create(:organization)
      @user = FactoryGirl.create(:user)
      @owner = FactoryGirl.create(:organization_user, user: @user_logged,
                                                      organization: @organization)
      @member = FactoryGirl.create(:organization_user, user: @user,
                                                       organization: @organization)
    end

    context 'when your are not logged in as the organization' do
      it 'should return forbidden' do
        delete :destroy, organization_id: @organization.id, id: @member.id
        expect(response.status).to eq(403)
      end
    end

    context 'when your are logged in as the organization and removed a member' do
      it 'should removed the member' do
        @user_logged.user_can_write_in_name_of(@organization)
        session[:current_organization_id] = @organization.id
        delete :destroy, organization_id: @organization.id, id: @member.id
        expect(response.status).to eq(204)
      end
    end

    context 'when your are logged in as the organization and removed your user' do
      it 'should removed your user and redirect' do
        @user_logged.user_can_write_in_name_of(@organization)
        session[:current_organization_id] = @organization.id
        delete :destroy, organization_id: @organization.id, id: @owner.id
        expect(response.status).to eq(200)
      end
    end

  end
end
