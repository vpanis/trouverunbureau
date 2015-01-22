require 'rails_helper'

RSpec.describe VenueReview, type: :model do
  subject { FactoryGirl.create(:venue_review) }

  # Relations
  it { should belong_to(:booking) }

  # Presence
  it { should validate_presence_of(:booking) }
  it { should validate_presence_of(:stars) }

  # Numericality
  it do
    should validate_numericality_of(:stars)
    .only_integer
    .is_less_than_or_equal_to(5)
    .is_greater_than_or_equal_to(1)
  end

  describe 'the venue\'s review changes' do

    before(:each) do
      @booking = FactoryGirl.create(:booking)
      @venue = @booking.space.venue
    end

    it 'increments the quantity when created' do
      quantity_reviews = @venue.quantity_reviews
      FactoryGirl.create(:venue_review, booking: @booking)
      @venue.reload
      expect(@venue.quantity_reviews).to eq(quantity_reviews + 1)
    end

    it 'increments the sum when created' do
      reviews_sum = @venue.reviews_sum
      r = FactoryGirl.create(:venue_review, booking: @booking)
      @venue.reload
      expect(@venue.reviews_sum).to eq(reviews_sum + r.stars)
    end

    it 'changes rating when created' do
      quantity_reviews = @venue.quantity_reviews
      reviews_sum = @venue.reviews_sum
      r = FactoryGirl.create(:venue_review, booking: @booking)
      @venue.reload
      expect(@venue.rating).to eq((reviews_sum + r.stars) / ((quantity_reviews + 1) * 1.0))
    end

    describe 'deactivate an active review' do

      before(:each) do
        @review = FactoryGirl.create(:venue_review, booking: @booking)
        @venue.reload
      end

      it 'decrease the quantity' do
        quantity_reviews = @venue.quantity_reviews
        @review.deactivate!
        @venue.reload
        expect(@venue.quantity_reviews).to eq(quantity_reviews - 1)
      end

      it 'decrease the sum' do
        reviews_sum = @venue.reviews_sum
        @review.deactivate!
        @venue.reload
        expect(@venue.reviews_sum).to eq(reviews_sum - @review.stars)
      end

      it 'changes rating' do
        quantity_reviews = @venue.quantity_reviews
        reviews_sum = @venue.reviews_sum
        @review.deactivate!
        @venue.reload
        if @venue.quantity_reviews == 0
          new_rating = 0
        else
          new_rating = (reviews_sum - @review.stars) / ((quantity_reviews - 1) * 1.0)
        end
        expect(@venue.rating).to eq(new_rating)
      end

      describe 'reactivate a review' do
        before(:each) do
          @review.deactivate!
          @venue.reload
        end

        it 'increments the quantity' do
          quantity_reviews = @venue.quantity_reviews
          @review.activate!
          @venue.reload
          expect(@venue.quantity_reviews).to eq(quantity_reviews + 1)
        end

        it 'increments the sum' do
          reviews_sum = @venue.reviews_sum
          @review.activate!
          @venue.reload
          expect(@venue.reviews_sum).to eq(reviews_sum + @review.stars)
        end

        it 'changes rating' do
          quantity_reviews = @venue.quantity_reviews
          reviews_sum = @venue.reviews_sum
          @review.activate!
          @venue.reload
          new_rating = (reviews_sum + @review.stars) / ((quantity_reviews + 1) * 1.0)
          expect(@venue.rating).to eq(new_rating)
        end
      end
    end
  end
end
