class RenameReviewVenuesTableToVenueReviews < ActiveRecord::Migration
  def change
    rename_table :review_venues, :venue_reviews
  end
end
