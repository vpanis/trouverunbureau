require 'rails_helper'

RSpec.describe VenueCollectionAccountsController, type: :controller do
  describe 'GET venues/:id/collection_info' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        @venue = FactoryGirl.create(:venue, owner: @user_logged)
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      context 'when user logged in is the venue\'s owner' do
        it 'succeeds' do
          get :collection_account_info, id: @venue.id
          expect(response.status).to eq(200)
        end

        it 'assigns the requested venue to @venue' do
          get :collection_account_info, id: @venue.id
          expect(assigns(:venue)).to eq(@venue)
        end

        context 'when collection account exists' do
          it 'assigns it to @collection_account' do
            @venue.collection_account = FactoryGirl.build(:braintree_collection_account)
            @venue.save
            get :collection_account_info, id: @venue.id
            expect(response).to render_template :collection_account_info
            expect(assigns(:collection_account)).to eq(@venue.collection_account)
          end
        end

        context 'when the venue does not exist' do
          before { get :collection_account_info, id: -1 }

          it 'fails' do
            expect(response.status).to eq(404)
          end
        end # when the venue does not exist
      end

      context 'when the user logged in is not the venue\'s owner' do
        it 'fails' do
          another_venue = FactoryGirl.create(:venue)
          get :collection_account_info, id: another_venue.id
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe 'PATCH venues/:id/collection_account_info' do
    context 'when user logged in' do
      before(:each) do
        @user_logged = FactoryGirl.create(:user)
        @venue = FactoryGirl.create(:venue, owner: @user_logged, country_code: 'US')
        sign_in @user_logged
      end

      after(:each) do
        sign_out @user_logged
      end

      def valid_params
        {
          first_name: 'Jane', last_name: 'Doe', email: 'jane@14ladders.com', phone: '5553334444',
          date_of_birth: '1981-11-19', individual_street_address: '111 Main St',
          individual_locality: 'Chicago', individual_region: 'IL', individual_postal_code: '60622',
          legal_name: 'Jane\'s Ladders', dba_name: 'Jane\'s Ladders', tax_id: '98-7654321',
          business_street_address: '111 Main St', business_locality: 'Chicago',
          business_region: 'IL', business_postal_code: '60622', descriptor: 'Blue Ladders',
          account_number: '1123581321', routing_number: '071101307'
        }
      end

      context 'when user logged in is the venue\'s owner' do
        context 'when the venue has no collection account' do
          it 'it fails if no params have been sent' do
            patch :edit_collection_account, id: @venue.id
            expect(response.status).to eq(400)
          end

          it 'it succeeds' do
            patch :edit_collection_account, id: @venue.id,
                                            braintree_collection_account: valid_params
            expect(response.status).to eq(201)
          end

          it 'doesn\'t create the collection account if its invalid data' do
            patch :edit_collection_account, id: @venue.id
            expect(@venue.collection_account.present?).to eq(false)
          end

          it 'if succeeds, enqueue a Payments::Braintree::SubMerchantAccountWorker\'s job' do
            assert_equal 0, Payments::Braintree::SubMerchantAccountWorker.jobs.size
            patch :edit_collection_account, id: @venue.id,
                                            braintree_collection_account: valid_params
            expect(response.status).to eq(201)
            assert_equal 1, Payments::Braintree::SubMerchantAccountWorker.jobs.size
          end

          it 'if fails, doesn\'t enqueue a Payments::Braintree::SubMerchantAccountWorker\'s job' do
            assert_equal 0, Payments::Braintree::SubMerchantAccountWorker.jobs.size
            patch :edit_collection_account, id: @venue.id
            expect(response.status).to eq(400)
            assert_equal 0, Payments::Braintree::SubMerchantAccountWorker.jobs.size
          end
        end
      end

      context 'when user logged in is not the venue\'s owner' do
        it 'fails' do
          another_venue = FactoryGirl.create(:venue)
          patch :collection_account_info, id: another_venue.id
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
