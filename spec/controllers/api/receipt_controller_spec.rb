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

    context 'when the booking exists' do
      context 'when user has permissions' do
        context 'when booking is paid' do
          let!(:a_booking) { create(:booking, owner: @user, state: :paid) }

          it 'succeeds' do
            post :create, id: a_booking.id
            expect(response.status).to eq(204)
          end

          it 'should create the receipt' do
            post :create, id: a_booking.id
            receipts = Receipt.all
            expect(receipts.size).to eq(1)
            expect(receipts.first.booking_id).to eq(a_booking.id)
          end
        end

        context 'when booking isn\'t paid' do
          let!(:a_booking) { create(:booking, owner: @user) }

          it 'fails' do
            post :create, id: a_booking.id
            expect(response.status).to eq(412)
          end
        end

      end

      context 'when user hasn\'t permissions' do
        let!(:a_booking) { create(:booking, state: :paid) }

        it 'fails' do
          post :create, id: a_booking.id
          expect(response.status).to eq(403)
        end
      end
    end

    context 'when the booking doesn\'t exists' do
      before { post :create, id: -1 }

      it 'fails' do
        expect(response.status).to eq(404)
      end
    end

  end

  describe 'GET bookings/:id/show_receipt' do

    context 'when the booking exists' do
      context 'when user has permissions' do
        context 'when user is booking owner' do
          context 'when booking is paid' do
            let!(:a_booking) { create(:booking, owner: @user, state: :paid) }
            let!(:a_receipt) do
              create(:receipt, booking: a_booking, guest_first_name: @user.first_name,
                     guest_last_name: @user.last_name, guest_avatar: @user.avatar,
                     guest_location: @user.location)
            end

            it 'succeeds' do
              get :show, id: a_booking.id
              expect(response.status).to eq(200)
            end

            it 'should retrieve the receipt' do
              get :show, id: a_booking.id
              receipt = JSON.parse(body['receipt'].to_json)
              real_receipt = JSON.parse(ReceiptSerializer.new(a_receipt).to_json)['receipt']
              expect(receipt).to eq(real_receipt)
              expect(receipt['owner']['first_name']).to eq(@user.first_name)
              expect(receipt['owner']['last_name']).to eq(@user.last_name)
              expect(receipt['owner']['avatar']).to eq(@user.avatar.url)
              expect(receipt['owner']['location']).to eq(@user.location)
            end
          end

          context 'when booking isn\'t paid' do
            let!(:a_booking) { create(:booking, owner: @user) }

            it 'fails' do
              get :show, id: a_booking.id
              expect(response.status).to eq(412)
            end
          end
        end

        context 'when user is booking venue owner' do
          context 'when booking is paid' do
            let(:a_venue) { create(:venue, owner: @user) }
            let(:a_space) { create(:space, venue: a_venue) }
            let(:a_booking) { create(:booking, space: a_space, state: :paid) }
            let!(:a_receipt) do
              create(:receipt, booking: a_booking, guest_first_name: a_booking.owner.first_name,
                     guest_last_name: a_booking.owner.last_name,
                     guest_avatar: a_booking.owner.avatar,
                     guest_location: a_booking.owner.location)
            end
            it 'succeeds' do
              get :show, id: a_booking.id
              expect(response.status).to eq(200)
            end

            it 'should retrieve the receipt' do
              get :show, id: a_booking.id
              receipt = JSON.parse(body['receipt'].to_json)
              real_receipt = JSON.parse(ReceiptSerializer.new(a_receipt).to_json)['receipt']
              owner = a_booking.owner
              expect(receipt).to eq(real_receipt)
              expect(receipt['owner']['first_name']).to eq(owner.first_name)
              expect(receipt['owner']['last_name']).to eq(owner.last_name)
              expect(receipt['owner']['avatar']).to eq(owner.avatar.url)
              expect(receipt['owner']['location']).to eq(owner.location)
            end
          end

          context 'when booking isn\'t paid' do
            let!(:a_booking) { create(:booking, owner: @user) }

            it 'fails' do
              get :show, id: a_booking.id
              expect(response.status).to eq(412)
            end
          end
        end
      end

      context 'when user hasn\'t permissions' do
        let!(:a_booking) { create(:booking, state: :paid) }
        let!(:a_receipt) { create(:receipt, booking: a_booking) }

        it 'fails' do
          get :show, id: a_booking.id
          expect(response.status).to eq(403)
        end
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
