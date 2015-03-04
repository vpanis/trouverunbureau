require 'rails_helper'

describe Api::V1::ReceiptController do
  let(:body) { JSON.parse(response.body) if response.body.present? }
  before(:each) do
    @organization = FactoryGirl.create(:organization)
    @user = @organization.users.first
    sign_in @user
  end

  after(:each) do
    sign_in @user
  end

  describe 'POST bookings/:id/create:receipt' do

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

  describe 'GET bookings/:id/show_receipt' do

    context 'when the booking exists' do

      let(:a_booking) { create(:booking, owner: @user, state: :paid) }
      let(:a_receipt) { create(:receipt, booking: a_booking) }
      before { get :show, id: a_booking.id }

      it 'succeeds' do
        expect(response.status).to eq(200)
      end

      it 'should retrieve the receipt' do
        get :show, id: a_booking.id
        byebug
        receipt = JSON.parse(body['receipt'].to_json)
        expect(receipt).to eq(JSON.parse(ReceiptSerializer.new(a_receipt).to_json)['receipt'])
      end
    end

    context 'when the booking does not exists' do
      before { get :show, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end
  end

end
