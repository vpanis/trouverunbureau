require 'rails_helper'

RSpec.describe MangopayCollectionAccount, type: :model do
  # Relations
  it { should have_one(:venue) }

  # Enums
  it do
    should define_enum_for(:status)
      .with([:base, :processing, :accepted, :rejected, :error_updating])
  end

  # Callbacks
  context 'callbacks' do
    it { is_expected.to callback(:cut_important_data).before(:save) }
  end

  # Presence
  describe 'Presence' do
    pending
  end

  describe '#json_data_for_mangopay' do
    pending
  end

  describe '#generic_account_last_4' do
    before do
      allow(subject).to receive(:iban_last_4).and_return(1234)
      allow(subject).to receive(:account_number_last_4).and_return(6789)
    end

    it 'returns last 4 iban numbers if bank_type is IBAN' do
      allow(subject).to receive(:bank_type).and_return('IBAN')
      expect(subject.generic_account_last_4).to eq(1234)
    end

    it 'returns last 4 account numbers if bank_type is NOT IBAN' do
      allow(subject).to receive(:bank_type).and_return('NOT_IBAN')
      expect(subject.generic_account_last_4).to eq(6789)
    end
  end

  describe '#person?' do
    it 'returns true if legal_person_type is PERSON' do
      allow(subject).to receive(:legal_person_type).and_return('PERSON')
      expect(subject.person?).to be_truthy
    end

    it 'returns false if legal_person_type is NOT PERSON' do
      expect(subject.person?).to be_falsey
    end
  end
end
