require 'rails_helper'

describe Api::V1::UsersController do

  before(:each) do
    @organization = FactoryGirl.create(:organization)
    @user = @organization.users.first
    sign_in @user
  end

  after(:each) do
    sign_in @user
  end

  describe 'POST users/:id/login_as_organization' do

    context 'when the user is in the organization' do

      it 'succeeds' do
        post :login_as_organization, id: @user.id, organization_id: @organization.id
        expect(response.status).to eq(204)
      end
    end

    context 'when the user is not in the organization' do
      let(:organization2) { create(:organization) }
      before { post :login_as_organization, id: @user.id, organization_id: organization2.id }

      it 'fails' do
        expect(response.status).to eq(403)
      end
    end

    context 'when the organization does not exists' do
      before { post :login_as_organization, id: @user.id, organization_id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'DELETE users/:id/login_as_organization' do
    context 'when the user is logged in' do
      it 'succeeds' do
        delete :reset_organization, id: @user.id
        expect(response.status).to eq(204)
      end
    end
  end
end
