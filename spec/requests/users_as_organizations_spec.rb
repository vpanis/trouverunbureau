require 'rails_helper'
require 'requests_helper'

describe 'Users as Organization', type: :request do

  before(:each) do
    @user = FactoryGirl.create(:user, password: '12341234')
    @organization = FactoryGirl.create(:organization, user: @user)
    devise_requests_login(@user.email, '12341234')
  end

  after(:each) do
    devise_requests_logout
  end

  context 'when the user is in the organization' do

    it 'succeeds' do
      post "/api/v1/users/#{@user.id}/login_as_organization", organization_id: @organization.id
      expect(response.status).to eq(204)
    end

    context 'when tries a request that uses the organization' do
      let!(:venue) { create(:venue, :with_spaces) }
      let!(:booking1) { create(:booking, owner: @user, space: venue.spaces[0]) }
      let!(:booking2) { create(:booking, owner: @organization, space: venue.spaces[0]) }
      let!(:cl_review1) { create(:client_review, booking: booking1) }
      let!(:cl_review2) { create(:client_review, booking: booking2) }
      let!(:organization2) { create(:organization, user: @user) }
      let!(:booking3) { create(:booking, owner: organization2, space: venue.spaces[0]) }
      let!(:cl_review3) { create(:client_review, booking: booking3) }

      before do
        post "/api/v1/users/#{@user.id}/login_as_organization", organization_id: @organization.id
      end

      it 'retrieves the organization data' do
        get "/api/v1/clients/#{@organization.id}/reviews", type: 'Organization'
        expect(response.status).to eq(200)
        cl_review2_json = JSON.parse(ClientReviewSerializer.new(cl_review2)
                                     .to_json)['client_review']
        expect(JSON.parse(body)['reviews']).to contain_exactly(cl_review2_json)
      end

      context 'switch organizations' do
        it 'retrieves the other organization data' do
          get "/api/v1/clients/#{@organization.id}/reviews", type: 'Organization'
          expect(response.status).to eq(200)

          get "/api/v1/clients/#{organization2.id}/reviews", type: 'Organization'
          expect(response.status).to eq(403)

          post "/api/v1/users/#{@user.id}/login_as_organization", organization_id:
            organization2.id

          get "/api/v1/clients/#{organization2.id}/reviews", type: 'Organization'
          expect(response.status).to eq(200)
          cl_review3_json = JSON.parse(ClientReviewSerializer.new(cl_review3)
                                       .to_json)['client_review']
          expect(JSON.parse(body)['reviews']).to contain_exactly(cl_review3_json)
        end
      end
    end
  end
end
