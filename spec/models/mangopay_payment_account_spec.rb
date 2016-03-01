require 'rails_helper'

RSpec.describe MangopayPaymentAccount, type: :model do
  # Relations
  it { should have_many(:mangopay_credit_cards) }
  it { should belong_to(:buyer) }

  # Enums
  it do
    should define_enum_for(:status)
      .with([:base, :processing, :accepted, :rejected])
  end

  # Callbacks
  context 'callbacks' do
    it { is_expected.to callback(:initialize_fields).after(:initialize) }

    it 'sets status :base as default' do
      expect(subject.status).to eq(:base.to_s)
    end

    it 'overrides status :base as default if provided' do
      mpa = MangopayPaymentAccount.new(status: MangopayPaymentAccount.statuses[:accepted])
      expect(mpa.status).to eq(:accepted.to_s)
    end
  end

  describe '#active?' do
    it 'returns true if status is :accepted' do
      allow(subject).to receive(:status).and_return(MangopayPaymentAccount.statuses[:accepted])
      expect(subject.active?).to be_truthy
    end

    it 'returns false if status is not :accepted' do
      allow(subject).to receive(:status).and_return(MangopayPaymentAccount.statuses[:base])
      expect(subject.active?).to be_falsey
    end
  end
end
