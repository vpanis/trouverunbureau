require 'rails_helper'

RSpec.describe MangopayCreditCard, type: :model do
  # Relations
  it { should belong_to(:mangopay_payment_account) }

  # Enums
  it do
    should define_enum_for(:status)
      .with([:registering, :needs_validation, :failed, :created])
  end

  # Presence
  it { should validate_presence_of(:mangopay_payment_account) }
  it { should validate_presence_of(:registration_expiration_date) }
  it { should validate_presence_of(:status) }

  # Inclusion
  it { should validate_inclusion_of(:currency).in_array(MangopayCreditCard::CURRENCIES) }

  # Scopes
  context 'scopes' do
    before do
      MangopayCreditCard.statuses.keys.each do |s|
        create(:mangopay_credit_card, status: s)
      end
    end

    describe '#activated' do
      it 'only returns the ones with status [:created]' do
        expect(MangopayCreditCard.activated.to_a).to eq(MangopayCreditCard.where(status: MangopayCreditCard.statuses[:created]).to_a)
      end
    end

    describe '#not_activated' do
      it 'only returns the ones with status different than [:created]' do
        expect(MangopayCreditCard.not_activated.to_a).to eq(MangopayCreditCard.where.not(status: MangopayCreditCard.statuses[:created]).to_a)
      end
    end
  end
end
