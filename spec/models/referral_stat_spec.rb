require 'rails_helper'

RSpec.describe ReferralStat, type: :model do

  let!(:user1)   { create(:user) }
  let!(:venue1)  { create(:venue, :with_spaces, :with_venue_hours, owner: user1) }

  context 'When no invitations have been made' do
    context 'When the user has only one venue' do
      before(:each) { ReferralStat.refresh_view }

      it 'contains a stat with a multiplier equal to 1' do
        expect(venue1.referral_stat.multiplier).to eq(1)
      end
      it 'creates only one stat' do
        expect(ReferralStat.count).to eq(1)
      end
    end

    context 'When the user has more than one venue' do
      let!(:venue2)  { create(:venue, :with_spaces, :with_venue_hours, owner: user1) }
      before(:each) { ReferralStat.refresh_view }

      it 'creates a stat with a multiplier equal to 1 for all venues' do
        user1.venues.each do |venue|
          expect(venue.referral_stat.multiplier).to eq(1)
        end
      end
      it 'creates one stat per venue' do
        expect(ReferralStat.count).to eq(2)
      end
    end
  end

  context 'When invitations were made' do
    let!(:user2)    { create(:user) }
    let!(:invitee1) { create(:user, invited_by: user1, invitation_token: 'abc') }
    let!(:invitee2) { create(:user, invited_by: user2, invitation_token: 'abcd') }

    context 'When no invitation has been accepted' do
      before(:each) { ReferralStat.refresh_view }

      it 'Keeps the user\'s venue multiplier equal to 1' do
        expect(venue1.referral_stat.multiplier).to eq(1)
      end
    end

    context 'When an invitation has been accepted' do
      before(:each) do
        invitee1.accept_invitation!
        invitee2.accept_invitation!
        ReferralStat.refresh_view
      end

      it 'should set the multiplier equal to #accepted_invitations/#total_accepted_invitations' do
        # for this example, the multiplier should be 1.5
        expect(venue1.referral_stat.multiplier).to eq(1.5)
      end
    end

    context 'When an invitation was accepted more than a month ago' do
      before(:each) do
        invitee1.accept_invitation!
        invitee1.update_attributes(invitation_accepted_at: Date.current - 2.months)
        invitee2.accept_invitation!
        invitee2.update_attributes(invitation_accepted_at: Date.current - 2.months)
        ReferralStat.refresh_view
      end

      it 'does not take into account the invitation' do
        # for this example, the multiplier should be 1.5
        expect(venue1.referral_stat.multiplier).to eq(1)
      end
    end
  end
end
