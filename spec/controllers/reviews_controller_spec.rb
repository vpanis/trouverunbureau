require 'rails_helper'

describe ReviewsController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) { create(:user) }

  describe 'GET bookings/:id/venue_review' do
    context 'a user is logged in' do
      before(:each) { sign_in user }
      context 'the user is the booking\'s client' do
        context 'booking\'s from date is before now' do
          let(:from_date) { DateTime.now - 1.second }

          context 'booking\'s state is PAID' do
            let(:booking) do
              create(:booking, owner: user, state: Booking.states[:paid], from: from_date)
            end

            context 'a venue review does not exist for that booking' do
              before { get :new_venue_review, id: booking.id }

              it 'succeeds' do
                expect(response.status).to eq(200)
              end

              it 'assings the booking to @booking' do
                expect(assigns(:booking)).to eq(booking)
              end

              it 'creates a VenueReview and assigns it to @review' do
                expect(assigns(:review)).to be_present
                expect(assigns(:review).booking).to eq(booking)
                expect(assigns(:review).class.name).to eq('VenueReview')
              end

              it 'renders the :new_venue_review template' do
                expect(response).to render_template :new_venue_review
              end
            end # a client review does not exist for that booking

            context 'a venue review exists for that booking' do
              let!(:venue_review) { create(:venue_review, booking: booking) }

              it 'is forbidden' do
                get :new_venue_review, id: booking.id
                expect(response.status).to eq(403)
              end
            end
          end # booking's state is PAID

          context 'booking\'s state is not PAID' do
            let(:booking) do
              create(:booking, owner: user, state: Booking.states[:pending_payment],
                               from: from_date)
            end

            it 'is forbidden' do
              get :new_venue_review, id: booking.id
              expect(response.status).to eq(403)
            end
          end
        end # booking's from date is before now

        context 'booking\'s from date is after now' do
          let(:from_date) { DateTime.now + 1.second }
          let(:booking) do
            create(:booking, owner: user, state: Booking.states[:paid], from: from_date)
          end

          it 'is forbidden' do
            get :new_venue_review, id: booking.id
            expect(response.status).to eq(403)
          end
        end
      end # the user is the booking's client

      context 'the user is not the booking\'s client' do
        let(:booking) { create(:booking) }

        it 'is forbidden' do
          get :new_venue_review, id: booking.id
          expect(response.status).to eq(403)
        end
      end

      context 'the booking does not exist' do
        it 'fails' do
          get :new_venue_review, id: -1
          expect(response.status).to eq(404)
        end
      end
    end # a user is logged in

    context 'no user is logged in' do
      let(:booking) { create(:booking) }

      it 'is redirected to login' do
        get :new_venue_review, id: booking.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end
  end # GET bookings/:id/venue_review

  describe 'GET bookings/:id/client_review' do
    context 'a user is logged in' do
      before(:each) { sign_in user }
      context 'the user is the venue\'s owner' do
        let(:venue) { create(:venue, owner: user) }
        let(:space) { create(:space, venue: venue) }
        context 'booking\'s from date is before now' do
          context 'booking\'s state is PAID' do
            let(:from_date) { DateTime.now - 1.second }
            let(:booking) do
              create(:booking, space: space, state: Booking.states[:paid], from: from_date)
            end

            context 'a client review does not exist for that booking' do
              before { get :new_client_review, id: booking.id }

              it 'succeeds' do
                expect(response.status).to eq(200)
              end

              it 'assings the booking to @booking' do
                expect(assigns(:booking)).to eq(booking)
              end

              it 'creates a ClientReview and assigns it to @review' do
                expect(assigns(:review)).to be_present
                expect(assigns(:review).booking).to eq(booking)
              end

              it 'renders the :new_client_review template' do
                expect(response).to render_template :new_client_review
              end
            end # a client review does not exist for that booking

            context 'a client review exists for that booking' do
              let!(:client_review) { create(:client_review, booking: booking) }

              it 'is forbidden' do
                get :new_client_review, id: booking.id
                expect(response.status).to eq(403)
              end
            end
          end # booking's state is PAID

          context 'booking\'s state is not PAID' do
            let(:from_date) { DateTime.now + 1.second }
            let(:booking) do
              create(:booking, space: space, state: Booking.states[:pending_payment],
                               from: from_date)
            end

            it 'is forbidden' do
              get :new_client_review, id: booking.id
              expect(response.status).to eq(403)
            end
          end
        end # booking's from date is before now

        context 'booking\'s from date is after now' do
          let(:from_date) { DateTime.now + 1.second }
          let(:booking) do
            create(:booking, space: space, state: Booking.states[:paid], from: from_date)
          end

          it 'is forbidden' do
            get :new_client_review, id: booking.id
            expect(response.status).to eq(403)
          end
        end
      end # the user is the venue's owner

      context 'the user is not the venue\'s owner' do
        let(:booking) { create(:booking) }

        it 'is forbidden' do
          get :new_client_review, id: booking.id
          expect(response.status).to eq(403)
        end
      end

      context 'the booking does not exist' do
        it 'fails' do
          get :new_client_review, id: -1
          expect(response.status).to eq(404)
        end
      end
    end # a user is logged in

    context 'no user is logged in' do
      let(:booking) { create(:booking) }

      it 'is redirected to login' do
        get :new_client_review, id: booking.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end
  end # GET bookings/:id/client_review

  describe 'POST bookings/:id/venue_review' do
    context 'a user is logged in' do
      before(:each) { sign_in user }
      context 'the user is the booking\'s client' do
        context 'booking\'s from date is before now' do
          let(:from_date) { DateTime.now - 1.second }

          context 'booking\'s state is PAID' do
            let(:booking) do
              create(:booking, owner: user, state: Booking.states[:paid], from: from_date)
            end
            let(:stars) { 4 }
            let(:message) { 'My opinion' }
            let!(:old_rating) { booking.space.venue.rating }
            let!(:old_quantity_reviews) { booking.space.venue.quantity_reviews }
            let!(:old_reviews_sum) { booking.space.venue.reviews_sum }

            context 'a venue review does not exist for that booking' do
              before do
                params = { stars: 4, message: message }
                post :create_venue_review, id: booking.id, venue_review: params
              end

              it 'succeeds' do
                expect(response.status).to eq(302)
              end

              it 'creates a VenueReview' do
                expect(VenueReview.where(booking: booking)).not_to be_empty
                review = VenueReview.where(booking: booking).first
                expect(review.stars).to eq(stars)
                expect(review.message).to eq(message)
                expect(review.booking).to eq(booking)
              end

              it 'updates the venue rating' do
                venue = booking.space.venue
                venue.reload
                expect(venue.quantity_reviews).to eq(old_quantity_reviews + 1)
                expect(venue.reviews_sum).to eq(old_reviews_sum + stars)
                expect(venue.rating).to eq(venue.reviews_sum / venue.quantity_reviews)
              end

              it 'redirects to user profile' do
                expect(response.redirect_url).to eq(user_url(user))
              end
            end # a venue review does not exist for that booking

            context 'a venue review exists for that booking' do
              let!(:venue_review) { create(:venue_review, booking: booking) }

              before do
                post :create_venue_review, id: booking.id
              end

              it 'is forbidden' do
                expect(response.status).to eq(403)
              end

              it 'does not create another venue_review' do
                expect(VenueReview.where(booking: booking).size).to eq(1)
              end
            end
          end # booking's state is PAID

          context 'booking\'s state is not PAID' do
            let(:booking) do
              create(:booking, owner: user, state: Booking.states[:pending_payment],
                               from: from_date)
            end

            it 'is forbidden' do
              post :create_venue_review, id: booking.id
              expect(response.status).to eq(403)
            end
          end
        end # booking's from date is before now

        context 'booking\'s from date is after now' do
          let(:from_date) { DateTime.now + 1.second }
          let(:booking) do
            create(:booking, owner: user, state: Booking.states[:paid], from: from_date)
          end

          it 'is forbidden' do
            post :create_client_review, id: booking.id
            expect(response.status).to eq(403)
          end
        end
      end # the user is the booking's client

      context 'the user is not the booking\'s client' do
        let(:booking) { create(:booking) }

        it 'is forbidden' do
          post :create_venue_review, id: booking.id
          expect(response.status).to eq(403)
        end
      end

      context 'the booking does not exist' do
        it 'fails' do
          post :create_venue_review, id: -1
          expect(response.status).to eq(404)
        end
      end
    end # a user is logged in

    context 'no user is logged in' do
      let(:booking) { create(:booking) }

      it 'is redirected to login' do
        post :create_venue_review, id: booking.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end
  end # POST bookings/:id/venue_review

  describe 'POST bookings/:id/client_review' do
    context 'a user is logged in' do
      before(:each) { sign_in user }
      context 'the user is the venue\'s owner' do
        let(:venue) { create(:venue, owner: user) }
        let(:space) { create(:space, venue: venue) }

        context 'booking\'s from date is before now' do
          let(:from_date) { DateTime.now - 1.second }

          context 'booking\'s state is PAID' do
            let(:booking) do
              create(:booking, space: space, state: Booking.states[:paid], from: from_date)
            end
            let(:stars) { 4 }
            let(:message) { 'My opinion' }
            let!(:old_rating) { booking.owner.rating }
            let!(:old_quantity_reviews) { booking.owner.quantity_reviews }
            let!(:old_reviews_sum) { booking.owner.reviews_sum }

            context 'a client review does not exist for that booking' do
              before do
                params = { stars: 4, message: message }
                post :create_client_review, id: booking.id, client_review: params
              end

              it 'succeeds' do
                expect(response.status).to eq(302)
              end

              it 'creates a ClientReview' do
                expect(ClientReview.where(booking: booking)).not_to be_empty
                review = ClientReview.where(booking: booking).first
                expect(review.stars).to eq(stars)
                expect(review.message).to eq(message)
                expect(review.booking).to eq(booking)
              end

              it 'updates the client rating' do
                client = booking.owner
                client.reload
                expect(client.quantity_reviews).to eq(old_quantity_reviews + 1)
                expect(client.reviews_sum).to eq(old_reviews_sum + stars)
                expect(client.rating).to eq(client.reviews_sum / client.quantity_reviews)
              end

              it 'redirects to user profile' do
                expect(response.redirect_url).to eq(user_url(user))
              end
            end # a venue review does not exist for that booking

            context 'a client review exists for that booking' do
              let!(:client_review) { create(:client_review, booking: booking) }

              before do
                post :create_client_review, id: booking.id
              end

              it 'is forbidden' do
                expect(response.status).to eq(403)
              end

              it 'does not create another client_review' do
                expect(ClientReview.where(booking: booking).size).to eq(1)
              end
            end
          end # booking's state is PAID

          context 'booking\'s state is not PAID' do
            let(:booking) do
              create(:booking, space: space, state: Booking.states[:pending_payment],
                               from: from_date)
            end

            it 'is forbidden' do
              post :create_client_review, id: booking.id
              expect(response.status).to eq(403)
            end
          end
        end # booking's from date is before now

        context 'booking\'s from date is after now' do
          let(:from_date) { DateTime.now + 1.second }
          let(:booking) do
            create(:booking, space: space, state: Booking.states[:paid], from: from_date)
          end

          it 'is forbidden' do
            post :create_client_review, id: booking.id
            expect(response.status).to eq(403)
          end
        end
      end # the user is the venues's owner

      context 'the user is not the venue\'s owner' do
        let(:booking) { create(:booking) }

        it 'is forbidden' do
          post :create_client_review, id: booking.id
          expect(response.status).to eq(403)
        end
      end

      context 'the booking does not exist' do
        it 'fails' do
          post :create_client_review, id: -1
          expect(response.status).to eq(404)
        end
      end
    end # a user is logged in

    context 'no user is logged in' do
      let(:booking) { create(:booking) }

      it 'is redirected to login' do
        post :create_client_review, id: booking.id
        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(new_user_session_url)
      end
    end

  end # POST bookings/:id/client_review
end
