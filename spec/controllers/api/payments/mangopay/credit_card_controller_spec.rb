require 'rails_helper'

RSpec.describe Api::V1::Payments::Mangopay::CreditCardController, type: :controller do
  let(:body) { JSON.parse(response.body) if response.body.present? }

  describe 'POST /mangopay/card_registration' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      it 'fails when user has no mangopay payment account' do
        post :card_registration, currency: 'eur'
        expect(response.status).to eq(412)
      end

      context 'when user has a mangopay payment account' do
        before(:each) do
          @mpa = FactoryGirl.create(:mangopay_payment_account, buyer: @user_logged)
        end

        it 'fails when it sends an invalid currency' do
          post :card_registration, currency: 'rrrr'
          expect(response.status).to eq(400)
        end

        context 'when it sends a valid currency' do
          before(:each) do
            post :card_registration, currency: 'eur'
          end

          it 'success' do
            expect(response.status).to eq(200)
          end

          it 'returns the mangopay_credit_card_id' do
            @mpa.reload
            credit_card = @mpa.mangopay_credit_cards.last
            expect(body['mangopay_credit_card_id']).to eq(credit_card.id)
          end

          it 'must enqueue a Payments::Mangopay::CardRegistrationWorker job with the card id' do
            @mpa.reload
            credit_card = @mpa.mangopay_credit_cards.last
            expect(::Payments::Mangopay::CardRegistrationWorker)
              .to have_enqueued_job(credit_card.id)
          end
        end
      end
    end

    it 'fails when the user is not logged in' do
      post :card_registration, currency: 'eur'
      expect(response.status).to eq(302)
    end
  end

  describe 'GET /mangopay/new_card_info?mangopay_credit_card_id' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      it 'fails when user has no mangopay payment account' do
        get :new_card_info
        expect(response.status).to eq(412)
      end

      context 'when user has a mangopay payment account' do
        before(:each) do
          @mpa = FactoryGirl.create(:mangopay_payment_account, buyer: @user_logged)
        end

        it 'fails when it doesn\'t send a mangopay_credit_card_id' do
          get :new_card_info
          expect(response.status).to eq(400)
        end

        it 'fails when it sends an invalid mangopay_credit_card_id' do
          get :new_card_info, mangopay_credit_card_id: -1
          expect(response.status).to eq(400)
        end

        context 'when it sends a valid currency' do
          before(:each) do
            @mcc = FactoryGirl.create(:mangopay_credit_card, mangopay_payment_account: @mpa)
          end

          it 'success' do
            get :new_card_info, mangopay_credit_card_id: @mcc.id
            expect(response.status).to eq(202)
          end

          it 'returns nil if the mangopay_credit_card is in status :registering' do
            expect(@mcc.status).to eq('registering')
            get :new_card_info, mangopay_credit_card_id: @mcc.id
            expect(response.status).to eq(202)
            expect(body).to be_nil
          end

          it 'fails if the mangopay_credit_card is in status :failed' do
            @mcc.update_attributes(status: MangopayCreditCard.statuses[:failed])
            get :new_card_info, mangopay_credit_card_id: @mcc.id
            expect(response.status).to eq(412)
          end

          it 'success if the mangopay_credit_card is in status :needs_validation' do
            @mcc.update_attributes(status: MangopayCreditCard.statuses[:needs_validation])
            get :new_card_info, mangopay_credit_card_id: @mcc.id
            expect(response.status).to eq(200)
          end

          it 'returns some data if the mangopay_credit_card is in status :needs_validation' do
            @mcc.update_attributes(status: MangopayCreditCard.statuses[:needs_validation],
                                   registration_id: 'mock',
                                   registration_access_key: 'mock',
                                   card_registration_url: 'mock',
                                   pre_registration_data: 'mock')
            get :new_card_info, mangopay_credit_card_id: @mcc.id
            expect(response.status).to eq(200)
            expect(body).to eq({ registration_id: 'mock',
                                 registration_access_key: 'mock',
                                 card_registration_url: 'mock',
                                 pre_registration_data: 'mock' }.stringify_keys)
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'fails' do
        get :new_card_info, currency: 'eur'
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'PUT /mangopay/save_credit_card' do

  end
end
# context 'when user logged in is the venue\'s owner' do
#   it 'succeeds' do
#     get :collection_account_info, id: @venue.id
#     expect(response.status).to eq(200)
#   end

#   it 'assigns the requested venue to @venue' do
#     get :collection_account_info, id: @venue.id
#     expect(assigns(:venue)).to eq(@venue)
#   end

#   context 'when collection account exists' do
#     it 'assigns it to @collection_account' do
#       @venue.collection_account = FactoryGirl.build(:braintree_collection_account)
#       @venue.save
#       get :collection_account_info, id: @venue.id
#       expect(response).to render_template :collection_account_info
#       expect(assigns(:collection_account)).to eq(@venue.collection_account)
#     end
#   end

#   context 'when the venue does not exist' do
#     before { get :collection_account_info, id: -1 }

#     it 'fails' do
#       expect(response.status).to eq(404)
#     end
#   end # when the venue does not exist
# end
