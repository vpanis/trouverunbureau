require 'rails_helper'

RSpec.describe User, type: :model do

  # Methods
  describe "#has_made_any_inquiries?" do

    subject { FactoryGirl.create(:user) }

    it "returns false for users without any inquiries" do
      expect(subject.has_made_any_inquiries?).not_to be
    end

    context "with inquiries" do

      let(:message) { instance_double("DMessage", exists?: true) }

      before(:each) do
        allow(Message).to receive(:by_user).and_return(message)
        allow(message).to receive(:pending_authorization).and_return(message)
      end

      it { expect(subject.has_made_any_inquiries?).to be }
    end

  end

  describe "#has_to_fill_inquiry_information?" do

    subject { FactoryGirl.create(:user) }
    inquiry_fields = [
        :location, :languages_spoken, :gender,
        :company_name, :profession, :interests
      ]

    before(:each) do
      inquiry_fields.each do |field|
        allow(subject).to receive(field).and_return(field.to_s)
      end
    end

    it "returns false for users with no blank inquiry fields" do
      expect(subject.has_to_fill_inquiry_information?).not_to be
    end

    shared_examples 'with inquiry field blank' do |field|
      it do
        allow(subject).to receive(field).and_return(nil)
        expect(subject.has_to_fill_inquiry_information?).to be

        allow(subject).to receive(field).and_return('')
        expect(subject.has_to_fill_inquiry_information?).to be
      end
    end

    context "when has blank field" do
      inquiry_fields.each do |field|
        it_behaves_like "with inquiry field blank", field
      end
    end

  end

  # Relations
  it { should have_many(:bookings) }
  it { should have_many(:organization_users) }
  it { should have_many(:organizations) }
  it { should have_many(:users_favorites) }
  it { should have_many(:venues) }
  it { should have_one(:braintree_payment_account) }
  it { should have_one(:mangopay_payment_account) }

  it do
    should have_many(:organization_venues)
      .through(:organizations)
      .source(:venues)
  end

  it do
    should have_many(:favorite_spaces)
      .through(:users_favorites)
      .source(:space)
  end

  # Uniquneness
  it { should validate_uniqueness_of(:email).case_insensitive }

  # Presence
  it { should validate_presence_of(:country_of_residence) }
  it { should validate_presence_of(:date_of_birth) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:nationality) }

  # it { should validate_presence_of(:password).on(:create) }

  # Numericality
  it do
    should validate_numericality_of(:rating)
    .is_less_than_or_equal_to(5)
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:quantity_reviews)
    .only_integer
    .is_greater_than_or_equal_to(0)
  end

  it do
    should validate_numericality_of(:reviews_sum)
    .only_integer
    .is_greater_than_or_equal_to(0)
  end

  # Inclusion
  it do
    should validate_inclusion_of(:language).in_array(User::LANGUAGES.map(&:to_s))
  end

  it do
    should validate_inclusion_of(:gender).in_array(User::GENDERS.map(&:to_s))
    should allow_value('').for(:gender)
    should allow_value(nil).for(:gender)
  end

  it do
    should validate_inclusion_of(:profession).in_array(Venue::PROFESSIONS.map(&:to_s))
  end

  it 'should accept a nil email if the provider is present' do
    user = User.create(first_name: 'test', last_name: 'master', password: 'testtest',
                       provider: 'test', gender: 'f', nationality: 'FR',
                       country_of_residence: 'FR', date_of_birth: Time.current.advance(years: -23),
                       profession: Venue::PROFESSIONS.first.to_s, company_name: 'Wolox')
    expect(user.valid?).to be_truthy
  end

  it 'shouldn\'t accept a nil email if the provider is nil' do
    user = User.create(first_name: 'test', last_name: 'super', password: 'testtest', gender: 'f',
                       profession: Venue::PROFESSIONS.first.to_s, company_name: 'Wolox')
    expect(user.valid?).to be_falsey
  end

  it 'should add an email error, if both provider and email are nil' do
    user = User.create(first_name: 'test', last_name: 'sir', password: 'testtest', gender: 'f',
                       profession: Venue::PROFESSIONS.first.to_s, company_name: 'Wolox')
    expect(user.errors[:email]).to be_present
  end

  it 'shouldn\'t accept invalid languages spoken' do
    user = FactoryGirl.build(:user, languages_spoken: ['not_existing_language'])
    expect(user.valid?).to be_falsey
  end

  it 'should accept nil language' do
    user = FactoryGirl.build(:user, language: nil)
    expect(user.valid?).to be_truthy
  end

  it 'should accept nil profession' do
    user = FactoryGirl.build(:user, profession: nil)
    expect(user.valid?).to be_truthy
  end

  # Callbacks

  context 'callbacks' do
    it { is_expected.to callback(:initialize_fields).after(:initialize) }
  end

end
