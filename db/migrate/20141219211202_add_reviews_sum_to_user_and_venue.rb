class AddReviewsSumToUserAndVenue < ActiveRecord::Migration
  def change
  	add_column :users, :reviews_sum, :integer
  	add_column :venues, :reviews_sum, :integer
  end
end
