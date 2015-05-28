require 'rails_helper'

describe Api::V1::VenuesController do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @venue = FactoryGirl.create(:venue)
    sign_in @user
  end

  after(:each) do
    sign_in @user
  end

  describe 'POST venues/:id/report' do
    context 'when the user is logged in' do
      it 'succeeds' do
        post :report, id: @venue.id
        expect(response.status).to eq(204)
      end
      it 'changes the venue status to reported' do
        post :report, id: @venue.id
        expect(@venue.reload.status).to eq('reported')
      end
    end
  end
end
