require 'rails_helper'

RSpec.describe ReferralStat, type: :model do

  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  before(:each) { ReferralStat.refresh_view }

  context 'When no invitations have been made' do
    it 'does not contain any referral stats' do
      expect { ReferralStat.count }.to eq(0)
    end
  end
end
