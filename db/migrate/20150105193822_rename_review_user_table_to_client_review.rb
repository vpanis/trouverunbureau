class RenameReviewUserTableToClientReview < ActiveRecord::Migration
  def change
    rename_table :review_users, :client_reviews
  end
end
