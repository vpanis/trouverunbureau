require 'rails_helper'

describe VenueDetailsController do

  let(:body) { JSON.parse(response.body) if response.body.present? }
  let!(:user) { create(:user) }

  describe 'GET venues/:id/details' do
    context 'a user is logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'the venue belongs to the user' do
        let!(:venue) { create(:venue, owner: user) }
        before { get :details, id: venue.id }

        it 'succeeds' do
          expect(response.status).to eq(200)
        end

        it 'assigns the requested venue to @venue' do
          expect(assigns(:venue)).to eq(venue)
        end

        it 'initializes hours and options' do
          expect(:modify_day_hours).to be_present
          expect(:custom_hours).to be_present
          expect(:professions_options).to be_present
        end

        it 'renders the :details template' do
          expect(response).to render_template :details
        end
      end # the venue belongs to the user

      context 'the venue does not belong to the user' do
        let!(:venue) { create(:venue) }

        it 'is forbidden' do
          get :details, id: venue.id
          expect(response.status).to eq(403)
        end
      end

      context 'the venue does not exist' do
        it 'fails' do
          get :details, id: -1
          expect(response.status).to eq(404)
        end
      end
    end # the user is logged in

    context 'no user is logged in' do
      context 'the venue exists' do
        let(:venue) { create(:venue) }

        it 'is redirected to login' do
          get :details, id: venue.id
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end
      context 'the venue does not exist' do
        it 'is redirected to login' do
          get :details, id: -1
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end
    end # no user is logged in
  end # GET venues/:id/details

  describe 'PATCH venues/:id/save_details' do
    context 'a user is logged in' do
      before(:each) { sign_in user }
      after(:each) { sign_out user }

      context 'the venue belongs to the user' do
        let!(:venue) { create(:venue, :with_time_zone, owner: user) }
        let(:new_description) { 'new description' }
        let(:new_professions) { "#{Venue::PROFESSIONS.first},#{Venue::PROFESSIONS.last}" }
        let(:new_rules) { 'new rules' }
        let(:space) { create(:space, capacity: 2, venue: venue) }
        let(:day_hours_attributes) do
          { '0' => { from: '1500', to: '1700', weekday: 0 },
            '1' => { id: venue.day_hours.first.id, from: '', to: '', weekday: '', _destroy: true },
            '2' => { from: '1600', to: '1700', weekday: 2 },
            '3' => { from: '', to: '', weekday: '', _destroy: true },
            '4' => { from: '', to: '', weekday: '', _destroy: true },
            '5' => { from: '', to: '', weekday: '', _destroy: true },
            '6' => { from: '', to: '', weekday: '', _destroy: true } }
        end

        context 'venue hours are valid' do
          before do
            params = { id: venue.id, description: new_description, professions: new_professions,
                       day_hours_attributes: day_hours_attributes, office_rules: new_rules }
            patch :save_details, id: venue.id, venue: params
            venue.reload
          end

          it 'succeeds' do
            expect(response.status).to eq(302)
          end

          it 'updates normal venue attributes' do
            expect(venue.description).to eq(new_description)
            expect(venue.office_rules).to eq(new_rules)
            expect(venue.professions).to include(Venue::PROFESSIONS.first.to_s)
            expect(venue.professions).to include(Venue::PROFESSIONS.last.to_s)
          end

          it 'updates venue_hours' do
            expect(venue.day_hours.count).to eq(2)
            day_hour_0 = venue.day_hours.where { weekday == 0 }.first
            day_hour_2 = venue.day_hours.where { weekday == 2 }.first
            expect(day_hour_0.from).to eq(day_hours_attributes['0'][:from].to_i)
            expect(day_hour_0.to).to eq(day_hours_attributes['0'][:to].to_i)
            expect(day_hour_2.from).to eq(day_hours_attributes['2'][:from].to_i)
            expect(day_hour_2.to).to eq(day_hours_attributes['2'][:to].to_i)
          end

          it 'renders the :amenities template' do
            expect(response.redirect_url).to eq(amenities_venue_url(venue))
          end
        end # venue hours are valid

        context 'venue hours are invalid' do
          before do
            invalid_hours = { '0' => { from: '1650', to: '1700', weekday: 0 },
                              '1' => { from: '', to: '', weekday: '', _destroy: true },
                              '2' => { from: '', to: '', weekday: 2, _destroy: true },
                              '3' => { from: '', to: '', weekday: '', _destroy: true },
                              '4' => { from: '', to: '', weekday: '', _destroy: true },
                              '5' => { from: '', to: '', weekday: '', _destroy: true },
                              '6' => { from: '', to: '', weekday: '', _destroy: true } }
            @params = { id: venue.id, day_hours_attributes: invalid_hours,
                       description: new_description, professions: new_professions }
          end

          it 'fails' do
            expect do
              patch :save_details, id: venue.id, venue: @params
            end.to raise_error(ActiveRecord::RecordInvalid)
          end
        end # venue hours are invalid

        context 'description is not present' do
          it 'fails' do
            params = { id: venue.id, description: nil, professions: new_professions,
                       day_hours_attributes: day_hours_attributes }
            patch :save_details, id: venue.id, venue: params
            expect(response.status).to eq(400)
          end
        end

        context 'when reducing venue_hours' do
          context 'when there are bookings' do
            let!(:booking) do
              create(:booking, space: space,
                               from: Time.current.advance(minutes: 2),
                               to: Time.current.advance(minutes: 10), state: :paid)
            end

            before do
              fewer_hours = { '0' => { from: '1600', to: '1700', weekday: 0 },
                              '1' => { from: '', to: '', weekday: '', _destroy: true },
                              '2' => { from: '', to: '', weekday: 2, _destroy: true },
                              '3' => { from: '', to: '', weekday: '', _destroy: true },
                              '4' => { from: '', to: '', weekday: '', _destroy: true },
                              '5' => { from: '', to: '', weekday: '', _destroy: true },
                              '6' => { from: '', to: '', weekday: '', _destroy: true } }
              venue_params = { id: venue.id, day_hours_attributes: fewer_hours }
              patch :save_details, id: venue.id, venue: venue_params
              venue.reload
            end

            it 'fails' do
              expect(response.status).to eq(412)
            end
          end # when there are bookings

          context 'where there aren\'t bookings of venue\' spaces' do
            let(:day_hour_2) do
              create(:venue_hour, weekday: 2, from: 1600, to: 1700,  venue_id: venue.id)
            end
            before do
              fewer_hours = { '0' => { id: venue.day_hours.first.id, from: '', to: '', weekday: '',
                                       _destroy: true },
                              '1' => { from: '', to: '', weekday: '', _destroy: true },
                              '2' => { id: day_hour_2.id, from: '0800', to: '1800', weekday: 2},
                              '3' => { from: '', to: '', weekday: '', _destroy: true },
                              '4' => { from: '', to: '', weekday: '', _destroy: true },
                              '5' => { from: '', to: '', weekday: '', _destroy: true },
                              '6' => { from: '', to: '', weekday: '', _destroy: true } }
              venue_params = { id: venue.id, day_hours_attributes: fewer_hours }
              patch :save_details, id: venue.id, venue: venue_params
              venue.reload
            end

            it 'succeeds' do
              expect(response.status).to eq(302)
              expect(venue.day_hours.count).to eq(1)
            end
          end # where there aren't bookings of venue' spaces
        end # when reducing venue_hours
      end # the venue belongs to the user

      context 'the venue does not belong to the user' do
        let(:venue) { create(:venue) }
        it 'is forbidden' do
          patch :save_details, id: venue.id
          expect(response.status).to eq(403)
        end
      end

      context 'the venue does not exist' do
        it 'fails' do
          patch :save_details, id: -1
          expect(response.status).to eq(404)
        end
      end
    end # a user is logged in

    context 'no user is logged in' do
      context 'the venue does exists' do
        let!(:venue) { create(:venue) }

        it 'is redirected to login' do
          patch :save_details, id: venue.id
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end

      context 'the venue does not exist' do
        it 'is redirected to login' do
          patch :save_details, id: -1
          expect(response.status).to eq(302)
          expect(response.redirect_url).to eq(new_user_session_url)
        end
      end
    end  # no user is logged in
  end # PATCH venues/:id/save_details
end
