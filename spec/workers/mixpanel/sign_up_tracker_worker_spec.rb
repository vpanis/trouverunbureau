require 'rails_helper'

module Mixpanel
  RSpec.describe SignUpTrackerWorker do
    describe '#perform' do
      it 'should queue a job to track an User signup in Mixpanel' do
        SignUpTrackerWorker.perform_async(123)

        expect(SignUpTrackerWorker).to have_enqueued_job(123)
      end
    end
  end
end
