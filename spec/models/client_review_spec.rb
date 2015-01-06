require 'rails_helper'

RSpec.describe ClientReview, type: :model do
  subject { FactoryGirl.create(:client_review) }

  # Relations
  it { should belong_to(:client) }
  it { should belong_to(:from_user) }

  # Presence
  it { should validate_presence_of(:client) }
  it { should validate_presence_of(:from_user) }
  it { should validate_presence_of(:stars) }

  # Numericality
  it do
    should validate_numericality_of(:stars)
    .only_integer
    .is_less_than_or_equal_to(5)
    .is_greater_than_or_equal_to(1)
  end

  describe 'the user\'s review changes' do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it 'increments the quantity when created' do
      quantity_reviews = @user.quantity_reviews
      FactoryGirl.create(:client_review, client: @user)
      @user.reload
      expect(@user.quantity_reviews).to eq(quantity_reviews + 1)
    end

    it 'increments the sum when created' do
      reviews_sum = @user.reviews_sum
      r = FactoryGirl.create(:client_review, client: @user)
      @user.reload
      expect(@user.reviews_sum).to eq(reviews_sum + r.stars)
    end

    it 'changes rating when created' do
      quantity_reviews = @user.quantity_reviews
      reviews_sum = @user.reviews_sum
      r = FactoryGirl.create(:client_review, client: @user)
      @user.reload
      expect(@user.rating).to eq((reviews_sum + r.stars) / ((quantity_reviews + 1) * 1.0))
    end

    describe 'deactivate an active review' do

      before(:each) do
        @review = FactoryGirl.create(:client_review, client: @user)
        @user.reload
      end

      it 'decrease the quantity' do
        quantity_reviews = @user.quantity_reviews
        @review.deactivate!
        @user.reload
        expect(@user.quantity_reviews).to eq(quantity_reviews - 1)
      end

      it 'decrease the sum' do
        reviews_sum = @user.reviews_sum
        @review.deactivate!
        @user.reload
        expect(@user.reviews_sum).to eq(reviews_sum - @review.stars)
      end

      it 'changes rating' do
        quantity_reviews = @user.quantity_reviews
        reviews_sum = @user.reviews_sum
        @review.deactivate!
        @user.reload
        if @user.quantity_reviews == 0
          new_rating = 0
        else
          new_rating = (reviews_sum - @review.stars) / ((quantity_reviews - 1) * 1.0)
        end
        expect(@user.rating).to eq(new_rating)
      end

      describe 'reactivate a review' do
        before(:each) do
          @review.deactivate!
          @user.reload
        end

        it 'increments the quantity' do
          quantity_reviews = @user.quantity_reviews
          @review.activate!
          @user.reload
          expect(@user.quantity_reviews).to eq(quantity_reviews + 1)
        end

        it 'increments the sum' do
          reviews_sum = @user.reviews_sum
          @review.activate!
          @user.reload
          expect(@user.reviews_sum).to eq(reviews_sum + @review.stars)
        end

        it 'changes rating' do
          quantity_reviews = @user.quantity_reviews
          reviews_sum = @user.reviews_sum
          @review.activate!
          @user.reload
          new_rating = (reviews_sum + @review.stars) / ((quantity_reviews + 1) * 1.0)
          expect(@user.rating).to eq(new_rating)
        end
      end
    end
  end
end
