require 'rails_helper'

module Payments
  module Mangopay
    RSpec.describe CollectionAccountWorker do
      let!(:mca) { FactoryGirl.create(:mangopay_collection_account) }

      it 'should not touch anything if the collection account does not exist' do
        initial_count = MangopayCollectionAccount.count
        expect(mca.created_at).to eq(mca.updated_at)

        subject.perform(-1, {})

        mca.reload
        expect(mca.created_at).to eq(mca.updated_at)
        expect(MangopayCollectionAccount.count).to eq(initial_count)
      end

      pending 'should properly call the MangoPay endpoints'
    end
  end
end
