require 'rails_helper'

RSpec.describe Message, type: :model do
  # Relations
  it { should belong_to(:booking) }
  it { should belong_to(:represented) }
  it { should belong_to(:user) }

  # Presence
  it { should validate_presence_of(:m_type) }
  it { should validate_presence_of(:represented) }

  context "if m_type is pending_authorization" do
    before { allow(subject).to receive(:m_type).and_return('pending_authorization') }
    it { should_not validate_presence_of(:user) }
  end

  context "if m_type is not pending_authorization or text" do
    before { allow(subject).to receive(:m_type).and_return('booking_change') }
    it { should validate_presence_of(:user) }
    it { should_not validate_presence_of(:text) }
  end

  context "if m_type is text" do
    before { allow(subject).to receive(:m_type).and_return('text') }
    it { should validate_presence_of(:text) }
  end

  # Enums
  it do
    should define_enum_for(:m_type).
      with([:text, :booking_change, :pending_authorization, :pending_payment, :paid,
            :cancelled, :denied, :expired, :payment_verification, :refunding, :error_refunding,
            :payment_error])
  end

  describe '#sender_is_guest?' do
    let(:message) { FactoryGirl.build(:message) }

    it 'returns false if the sender is NOT the guest' do
      allow(message).to receive(:user).and_return(User.new)
      expect(message.sender_is_guest?).to be_falsey
    end

    it 'returns true if the sender IS the guest' do
      expect(message.sender_is_guest?).to be_truthy
    end
  end

  describe '#destination_recipient' do
    it 'returns "host" if the sender IS the guest' do
      allow(subject).to receive(:sender_is_guest?).and_return(true)
      expect(subject.destination_recipient).to eq('host')
    end

    it 'returns "guest" if the sender is NOT the guest' do
      allow(subject).to receive(:sender_is_guest?).and_return(false)
      expect(subject.destination_recipient).to eq('guest')
    end
  end
end
