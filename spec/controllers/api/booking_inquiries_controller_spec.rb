require 'rails_helper'
require 'time_helper'

describe Api::V1::BookingInquiriesController do

  let(:body) { JSON.parse(response.body) if response.body.present? }

  before(:each) do
    @user_logged = FactoryGirl.create(:user)
    sign_in @user_logged
  end

  after(:each) do
    sign_out @user_logged
  end

  describe 'GET organizations/:id/inquiries' do
    let(:organization) { FactoryGirl.create(:organization, user: @user_logged) }

    it 'succeeds' do
      get :organization_inquiries, { id: organization.id },
          current_organization_id: organization.id
      expect(response.status).to eq(200)
    end

    context 'when the organization has inquiries' do
      before(:each) do
        @booking1 = FactoryGirl.create(:booking, owner: organization)
        @message1_b1 = FactoryGirl.create(:message, user: @booking1.space.venue.owner,
                                                    booking: @booking1,
                                                    represented: @booking1.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking2 = FactoryGirl.create(:booking, owner: organization, state: Booking.states[:paid])
        @message1_b2 = FactoryGirl.create(:message, user: @booking2.space.venue.owner,
                                                    booking: @booking2,
                                                    represented: @booking2.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking3 = FactoryGirl.create(:booking, owner: organization)
        @message1_b3 = FactoryGirl.create(:message, user: @booking3.space.venue.owner,
                                                    booking: @booking3,
                                                    represented: @booking3.space.venue.owner)
      end

      # The login is tested in the user_as_organization_spec, the way to logged as one
      # in the specs, is sendind the current_organization_id in the session (2nd hash)
      it 'doesn\'t retrieve the organization inquiries if is not logged as it' do
        get :organization_inquiries, id: organization.id
        expect(response.status).to eq(403)
      end

      it 'should retrieve inquiries ordered desc by the last message date' do
        get :organization_inquiries, { id: organization.id },
            current_organization_id: organization.id
        b1_json = JSON.parse(InquirySerializer.new(@booking1).to_json)
        b2_json = JSON.parse(InquirySerializer.new(@booking2).to_json)
        b3_json = JSON.parse(InquirySerializer.new(@booking3).to_json)
        expect(body['inquiries']).to match_array([b3_json['inquiry'], b1_json['inquiry'],
                                                  b2_json['inquiry']])
      end

      it 'should paginate inquiries' do
        page = 2
        amount =  1
        get :organization_inquiries, { id: organization.id, page: page, amount: amount },
            current_organization_id: organization.id

        expect(body['count']).to eql(3)
        expect(body['items_per_page']).to eql(amount)
        expect(body['current_page']).to eql(page)
        expect(body['inquiries'].size).to eql(amount)
      end
    end

    context 'when the logged user does not belongs to the organization' do
      it 'doesn\'t retrieve the organization inquiries' do
        organization2 = FactoryGirl.create(:organization)
        get :organization_inquiries, { id: organization2.id },
            current_organization_id: organization2.id
        expect(response.status).to eq(403)
      end
    end

    context 'when the user belongs to the organization but is logged as another one' do
      it 'doesn\'t retrieve the organization inquiries' do
        organization2 = FactoryGirl.create(:organization, user: @user_logged)
        get :organization_inquiries, { id: organization.id },
            current_organization_id: organization2.id
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'GET users/:id/inquiries' do
    it 'succeeds' do
      get :user_inquiries, id: @user_logged.id
      expect(response.status).to eq(200)
    end

    context 'when the user has inquiries' do
      before(:each) do
        @booking1 = FactoryGirl.create(:booking, owner: @user_logged)
        @message1_b1 = FactoryGirl.create(:message, user: @booking1.space.venue.owner,
                                                    booking: @booking1,
                                                    represented: @booking1.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking2 = FactoryGirl.create(:booking, owner: @user_logged, state: Booking.states[:paid])
        @message1_b2 = FactoryGirl.create(:message, user: @booking2.space.venue.owner,
                                                    booking: @booking2,
                                                    represented: @booking2.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking3 = FactoryGirl.create(:booking, owner: @user_logged)
        @message1_b3 = FactoryGirl.create(:message, user: @booking3.space.venue.owner,
                                                    booking: @booking3,
                                                    represented: @booking3.space.venue.owner)
      end

      it 'should retrieve inquiries ordered desc by the last message date' do
        get :user_inquiries, id: @user_logged.id
        b1_json = JSON.parse(InquirySerializer.new(@booking1).to_json)
        b2_json = JSON.parse(InquirySerializer.new(@booking2).to_json)
        b3_json = JSON.parse(InquirySerializer.new(@booking3).to_json)
        expect(body['inquiries']).to match_array([b3_json['inquiry'], b1_json['inquiry'],
                                                  b2_json['inquiry']])
      end

      it 'should paginate inquiries' do
        page = 2
        amount =  1
        get :user_inquiries, id: @user_logged.id, page: page, amount: amount

        expect(body['count']).to eql(3)
        expect(body['items_per_page']).to eql(amount)
        expect(body['current_page']).to eql(page)
        expect(body['inquiries'].size).to eql(amount)
      end

      it 'doesn\' let the user retrieve other users inquiries' do
        user2 = FactoryGirl.create(:user)
        get :user_inquiries, id: user2.id
        expect(response.status).to eq(403)
      end
    end

    context 'when the user is logged as an organization' do
      it 'doesn\'t retrieve the user inquiries' do
        organization = FactoryGirl.create(:organization, user: @user_logged)
        get :user_inquiries, { id: @user_logged.id }, current_organization_id: organization.id
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'GET organizations/:id/inquiries_with_news' do
    let(:organization) { FactoryGirl.create(:organization, user: @user_logged) }

    it 'succeeds' do
      get :organization_inquiries_with_news, { id: organization.id },
          current_organization_id: organization.id
      expect(response.status).to eq(200)
    end

    context 'when the organization has inquiries' do
      before(:each) do
        @booking1 = FactoryGirl.create(:booking, owner: organization)
        @message1_b1 = FactoryGirl.create(:message, user: @booking1.space.venue.owner,
                                                    booking: @booking1,
                                                    represented: @booking1.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking2 = FactoryGirl.create(:booking, owner: organization, state: Booking.states[:paid])
        @message1_b2 = FactoryGirl.create(:message, user: @booking2.space.venue.owner,
                                                    booking: @booking2,
                                                    represented: @booking2.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking3 = FactoryGirl.create(:booking, owner: organization)
        @message1_b3 = FactoryGirl.create(:message, user: @booking3.space.venue.owner,
                                                    booking: @booking3,
                                                    represented: @booking3.space.venue.owner)

        BookingManager.change_last_seen(@booking1, organization, @message1_b1.created_at)
      end

      # The login is tested in the user_as_organization_spec, the way to logged as one
      # in the specs, is sendind the current_organization_id in the session (2nd hash)
      it 'doesn\'t retrieve the organization inquiries if is not logged as it' do
        get :organization_inquiries_with_news, id: organization.id
        expect(response.status).to eq(403)
      end

      it 'should retrieve inquiries ordered desc by the last message date' do
        get :organization_inquiries_with_news, { id: organization.id },
            current_organization_id: organization.id
        b2_json = JSON.parse(InquirySerializer.new(@booking2).to_json)
        b3_json = JSON.parse(InquirySerializer.new(@booking3).to_json)
        expect(body['inquiries']).to match_array([b3_json['inquiry'], b2_json['inquiry']])
      end

      it 'should paginate inquiries' do
        page = 2
        amount =  1
        get :organization_inquiries_with_news, { id: organization.id, page: page, amount: amount },
            current_organization_id: organization.id

        expect(body['count']).to eql(2)
        expect(body['items_per_page']).to eql(amount)
        expect(body['current_page']).to eql(page)
        expect(body['inquiries'].size).to eql(amount)
      end
    end

    context 'when the logged user does not belongs to the organization' do
      it 'doesn\'t retrieve the organization inquiries' do
        organization2 = FactoryGirl.create(:organization)
        get :organization_inquiries_with_news, { id: organization2.id },
            current_organization_id: organization2.id
        expect(response.status).to eq(403)
      end
    end

    context 'when the user belongs to the organization but is logged as another one' do
      it 'doesn\'t retrieve the organization inquiries' do
        organization2 = FactoryGirl.create(:organization, user: @user_logged)
        get :organization_inquiries_with_news, { id: organization.id },
            current_organization_id: organization2.id
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'GET users/:id/inquiries_with_news' do
    it 'succeeds' do
      get :user_inquiries_with_news, id: @user_logged.id
      expect(response.status).to eq(200)
    end

    context 'when the user has inquiries with news' do
      before(:each) do
        @booking1 = FactoryGirl.create(:booking, owner: @user_logged)
        @message1_b1 = FactoryGirl.create(:message, user: @booking1.space.venue.owner,
                                                    booking: @booking1,
                                                    represented: @booking1.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking2 = FactoryGirl.create(:booking, owner: @user_logged, state: Booking.states[:paid])
        @message1_b2 = FactoryGirl.create(:message, user: @booking2.space.venue.owner,
                                                    booking: @booking2,
                                                    represented: @booking2.space.venue.owner)
        advance_in_time(seconds: 1)
        @booking3 = FactoryGirl.create(:booking, owner: @user_logged)
        @message1_b3 = FactoryGirl.create(:message, user: @booking3.space.venue.owner,
                                                    booking: @booking3,
                                                    represented: @booking3.space.venue.owner)

        BookingManager.change_last_seen(@booking1, @user_logged, @message1_b1.created_at)
      end

      it 'should retrieve inquiries ordered desc by the last message date' do
        get :user_inquiries_with_news, id: @user_logged.id
        b2_json = JSON.parse(InquirySerializer.new(@booking2).to_json)
        b3_json = JSON.parse(InquirySerializer.new(@booking3).to_json)
        expect(body['inquiries']).to match_array([b3_json['inquiry'], b2_json['inquiry']])
      end

      it 'should paginate inquiries' do
        page = 2
        amount =  1
        get :user_inquiries_with_news, id: @user_logged.id, page: page, amount: amount

        expect(body['count']).to eql(2)
        expect(body['items_per_page']).to eql(amount)
        expect(body['current_page']).to eql(page)
        expect(body['inquiries'].size).to eql(amount)
      end

      it 'doesn\' let the user retrieve other users inquiries' do
        user2 = FactoryGirl.create(:user)
        get :user_inquiries_with_news, id: user2.id
        expect(response.status).to eq(403)
      end

      it 'shouldn\'t retrieve the inquiries that have been read' do
        @booking2.owner_last_seen = @message1_b2.created_at
        @booking2.save
        get :user_inquiries_with_news, id: @user_logged.id
        b3_json = JSON.parse(InquirySerializer.new(@booking3).to_json)
        expect(body['inquiries']).to match_array([b3_json['inquiry']])
      end
    end

    context 'when the user is logged as an organization' do
      it 'doesn\'t retrieve the user inquiries' do
        organization = FactoryGirl.create(:organization, user: @user_logged)
        get :user_inquiries_with_news, { id: @user_logged.id },
            current_organization_id: organization.id
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'PUT inquiries/:id/last_seen_message' do
    before(:each) do
      @booking1 = FactoryGirl.create(:booking, owner: @user_logged)
      @message1_b1 = FactoryGirl.create(:message, user: @booking1.space.venue.owner,
                                                  booking: @booking1,
                                                  represented: @booking1.space.venue.owner)
      advance_in_time(seconds: 1)
      @booking2 = FactoryGirl.create(:booking, owner: @user_logged, state: Booking.states[:paid])
      @message1_b2 = FactoryGirl.create(:message, user: @booking2.space.venue.owner,
                                                  booking: @booking2,
                                                  represented: @booking2.space.venue.owner)
    end

    it 'succeeds' do
      put :last_seen_message, id: @booking1, message_id: @message1_b1
      expect(response.status).to eq(204)
    end

    it 'changes the last seen for that user in the booking' do
      put :last_seen_message, id: @booking1, message_id: @message1_b1
      @booking1.reload
      @message1_b1.reload
      expect(@booking1.owner_last_seen).to eq(@message1_b1.created_at)
    end
  end

  describe 'POST inquiries/:id/messages' do
    before(:each) do
      @booking1 = FactoryGirl.create(:booking, owner: @user_logged)
      @message1_b1 = FactoryGirl.create(:message, user: @booking1.space.venue.owner,
                                                  booking: @booking1,
                                                  represented: @booking1.space.venue.owner)
    end

    it 'succeeds' do
      post :add_message, id: @booking1, message: { text: Faker::Lorem.sentence }
      expect(response.status).to eq(200)
    end

    it 'creates and assign the message to the booking' do
      messages_before = @booking1.messages.count
      post :add_message, id: @booking1, message: { text: Faker::Lorem.sentence }
      expect(@booking1.messages.count).to eq(messages_before + 1)
    end

    it 'creates and assign the message with the user setted' do
      post :add_message, id: @booking1, message: { text: Faker::Lorem.sentence }
      @booking1.reload
      expect(@booking1.messages.last.user_id).to eq(@user_logged.id)
    end

    it 'fails if the message field is missing' do
      post :add_message, id: @booking1
      expect(response.status).to eq(400)
    end

    it 'fails if the text field is missing' do
      post :add_message, id: @booking1, message: {}
      expect(response.status).to eq(400)
    end

    it 'doesn\'t allow to create a message in another inquiry' do
      booking2 = FactoryGirl.create(:booking)
      post :add_message, id: booking2, message: { text: Faker::Lorem.sentence }
      expect(response.status).to eq(403)
    end

    it 'fails to create a message in a booking of the user\'s organizations (without login)' do
      organization = FactoryGirl.create(:organization, user: @user_logged)
      booking_org = FactoryGirl.create(:booking, owner: organization)
      post :add_message, id: booking_org, message: { text: Faker::Lorem.sentence }
      expect(response.status).to eq(403)
    end

    context 'logged as a organization' do
      let(:organization) { FactoryGirl.create(:organization, user: @user_logged) }
      before(:each) do
        @booking_org = FactoryGirl.create(:booking, owner: organization)
        @message1_org = FactoryGirl.create(:message, user: @booking_org.space.venue.owner,
                                                     booking: @booking_org,
                                                     represented: @booking_org.space.venue.owner)
      end

      it 'fails to create a message in a booking of the user' do
        post :add_message, { id: @booking1, message: { text: Faker::Lorem.sentence } },
             current_organization_id: organization.id
      end

      it 'creates and assign the message to the booking' do
        messages_before = @booking_org.messages.count
        post :add_message, { id: @booking_org, message: { text: Faker::Lorem.sentence } },
             current_organization_id: organization.id
        expect(@booking_org.messages.count).to eq(messages_before + 1)
      end

      it 'creates and assign the message with the organization and user setted' do
        post :add_message, { id: @booking_org, message: { text: Faker::Lorem.sentence } },
             current_organization_id: organization.id
        @booking_org.reload
        expect(@booking_org.messages.last.user_id).to eq(@user_logged.id)
        expect(@booking_org.messages.last.represented_id).to eq(organization.id)
      end
    end
  end

  describe 'GET inquiries/:id/messages' do
    before(:each) do
      @booking = FactoryGirl.create(:booking, owner: @user_logged)
    end

    it 'succeeds' do
      get :messages, id: @booking.id
      expect(response.status).to eq(200)
    end

    context 'when the user has inquiries with news' do

      before(:each) do
        @message1 = FactoryGirl.create(:message, user: @booking.space.venue.owner,
                                       booking: @booking, represented: @booking.space.venue.owner)
        advance_in_time(seconds: 2)
        @message2 = FactoryGirl.create(:message, user: @user_logged,
                                       booking: @booking, represented: @user_logged)
        advance_in_time(seconds: 2)
        @message3 = FactoryGirl.create(:message, user: @booking.space.venue.owner,
                                       booking: @booking, represented: @booking.space.venue.owner)
      end

      it 'should retrieve messages ordered desc by created_at' do
        get :messages, id: @booking.id
        m1_json = JSON.parse(MessageSerializer.new(@message1).to_json)
        m2_json = JSON.parse(MessageSerializer.new(@message2).to_json)
        m3_json = JSON.parse(MessageSerializer.new(@message3).to_json)
        expect(body['messages']).to match_array([m3_json['message'], m2_json['message'],
                                                 m1_json['message']])
      end

      it 'should paginate messages' do
        page = 2
        amount =  1
        get :messages, id: @booking.id, page: page, amount: amount

        expect(body['count']).to eql(3)
        expect(body['items_per_page']).to eql(amount)
        expect(body['current_page']).to eql(page)
        expect(body['messages'].size).to eql(amount)
      end

      it 'should get messages from a minimum date (not_included)' do
        get :messages, id: @booking.id, from: @message1.created_at.advance(seconds: 1)
        m2_json = JSON.parse(MessageSerializer.new(@message2).to_json)
        m3_json = JSON.parse(MessageSerializer.new(@message3).to_json)
        expect(body['messages']).to match_array([m3_json['message'], m2_json['message']])
      end

      it 'should get messages from a maximum date (not included)' do
        get :messages, id: @booking.id, to: @message2.created_at.advance(seconds: 1)
        m1_json = JSON.parse(MessageSerializer.new(@message1).to_json)
        m2_json = JSON.parse(MessageSerializer.new(@message2).to_json)
        expect(body['messages']).to match_array([m2_json['message'], m1_json['message']])
      end

      it 'should get messages from a date range (not included)' do
        get :messages, id: @booking.id, from: @message1.created_at.advance(seconds: 1),
            to: @message2.created_at.advance(seconds: 1)
        m2_json = JSON.parse(MessageSerializer.new(@message2).to_json)
        expect(body['messages']).to match_array([m2_json['message']])
      end

      it 'doesn\' let the user retrieve other users messages' do
        @booking1 = FactoryGirl.create(:booking)
        get :messages, id: @booking1.id
        expect(response.status).to eq(403)
      end
    end

    context 'when the user is logged as an organization' do
      it 'doesn\'t retrieve the user messages' do
        organization = FactoryGirl.create(:organization, user: @user_logged)
        get :messages, { id: @booking.id },
            current_organization_id: organization.id
        expect(response.status).to eq(403)
      end
    end
  end
end
