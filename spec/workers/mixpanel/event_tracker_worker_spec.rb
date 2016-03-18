require 'rails_helper'

module Mixpanel
  RSpec.describe EventTrackerWorker do
    describe '#perform' do
      let(:user_id) { 'test_user' }
      let(:event) { 'test_event' }

      it 'should queue a job to track an event in Mixpanel' do
        EventTrackerWorker.perform_async(user_id, event)

        expect(EventTrackerWorker).to have_enqueued_job(user_id, event)
      end
    end
  end
end
