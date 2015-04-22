require 'rails_helper'
require 'time_helper'

describe Api::V1::BookingsController do

  let(:body) { JSON.parse(response.body) if response.body.present? }

  before(:each) do
    @user_logged = FactoryGirl.create(:user)
    sign_in @user_logged
  end

  after(:each) do
    sign_out @user_logged
  end

  describe 'PUT inquiries/:id/accept' do
    before(:each) do
      @venue = FactoryGirl.create(:venue, :with_venue_hours, owner: @user_logged)
      @space = FactoryGirl.create(:space, venue: @venue, month_price: 300, quantity: 3)
      @booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:month])
    end

    it 'succeeds' do
      put :accept, id: @booking
      expect(response.status).to eq(201)
    end

    it 'changes the status of the booking, to pending payment' do
      put :accept, id: @booking
      @booking.reload
      expect(@booking.pending_payment?).to eq(true)
    end

    it 'adds a new message to the inquiry' do
      old_messages_count = @booking.messages.count
      put :accept, id: @booking
      @booking.reload
      expect(@booking.messages.count).to eq(old_messages_count + 1)
      expect(@booking.messages.last.pending_payment?).to eq(true)
    end

    it 'fails if the state it\'s not pending_authorization' do
      @booking.update_attributes(state: Booking.states[:paid])
      put :accept, id: @booking
      expect(response.status).to eq(400)
    end

    it 'fails if the booking\'s owner tries to accept it' do
      @booking = FactoryGirl.create(:booking, owner: @user_logged)
      put :accept, id: @booking
      expect(response.status).to eq(400)
    end
  end

  describe 'PUT inquiries/:id/cancel' do
    before(:each) do
      @venue = FactoryGirl.create(:venue, :with_venue_hours)
      @space = FactoryGirl.create(:space, venue: @venue, month_price: 300, quantity: 3)
      @booking = FactoryGirl.create(:booking, owner: @user_logged, space: @space,
                                    b_type: Booking.b_types[:month])
    end

    it 'succeeds' do
      put :cancel, id: @booking
      expect(response.status).to eq(201)
    end

    it 'changes the status of the booking, to cancel' do
      put :cancel, id: @booking
      @booking.reload
      expect(@booking.cancelled?).to eq(true)
    end

    it 'adds a new message to the inquiry' do
      old_messages_count = @booking.messages.count
      put :cancel, id: @booking
      @booking.reload
      expect(@booking.messages.count).to eq(old_messages_count + 1)
      expect(@booking.messages.last.cancelled?).to eq(true)
    end

    it 'fails if the venue\'s owner tries to cancel it' do
      @venue = FactoryGirl.create(:venue, :with_venue_hours, owner: @user_logged)
      @space = FactoryGirl.create(:space, venue: @venue, month_price: 300, quantity: 3)
      @booking = FactoryGirl.create(:booking, space: @space,
                                              b_type: Booking.b_types[:month])
      put :cancel, id: @booking
      expect(response.status).to eq(400)
    end
  end

  describe 'PUT inquiries/:id/deny' do
    before(:each) do
      @venue = FactoryGirl.create(:venue, :with_venue_hours, owner: @user_logged)
      @space = FactoryGirl.create(:space, venue: @venue, month_price: 300, quantity: 3)
      @booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:month])
    end

    it 'succeeds' do
      put :deny, id: @booking
      expect(response.status).to eq(201)
    end

    it 'changes the status of the booking, to cancel' do
      put :deny, id: @booking
      @booking.reload
      expect(@booking.denied?).to eq(true)
    end

    it 'adds a new message to the inquiry' do
      old_messages_count = @booking.messages.count
      put :deny, id: @booking
      @booking.reload
      expect(@booking.messages.count).to eq(old_messages_count + 1)
      expect(@booking.messages.last.denied?).to eq(true)
    end

    it 'fails if the booking\'s owner tries to cancel it' do
      @venue = FactoryGirl.create(:venue, :with_venue_hours)
      @space = FactoryGirl.create(:space, venue: @venue, month_price: 300, quantity: 3)
      @booking = FactoryGirl.create(:booking, space: @space, owner: @user_logged,
                                    b_type: Booking.b_types[:month])
      put :deny, id: @booking
      expect(response.status).to eq(400)
    end
  end

  describe 'PUT inquiries/:id/edit' do
    before(:each) do
      @venue = FactoryGirl.create(:venue, :with_venue_hours, owner: @user_logged)
      @space = FactoryGirl.create(:space, venue: @venue, month_price: 300, quantity: 3)
      @booking = FactoryGirl.create(:booking, space: @space, b_type: Booking.b_types[:month])
    end

    it 'succeeds' do
      put :update_booking, id: @booking, price: 10
      @booking.reload
      expect(@booking.price).to eq(10)
    end

    it 'fails caused by missing parameter' do
      put :update_booking, id: @booking, price: nil
      expect(response.status).to eq(400)
    end

    it 'fails caused by a negative price' do
      put :update_booking, id: @booking, price: -1
      expect(response.status).to eq(400)
    end
  end
end
