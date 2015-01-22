class AddBookingReferenceToReviews < ActiveRecord::Migration
  def change
    add_reference :client_reviews, :booking, index: true
    add_reference :venue_reviews, :booking, index: true
  end
end
