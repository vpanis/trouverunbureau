class RemoveBookingDuplicatedInfoFromReviews < ActiveRecord::Migration
  def change
    remove_reference :client_reviews, :client, polymorphic: true
    remove_reference :client_reviews, :from_user
    remove_reference :venue_reviews, :venue
    remove_reference :venue_reviews, :from_user
  end
end
