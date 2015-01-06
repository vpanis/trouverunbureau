class AddRatingsToUsersAndVenues < ActiveRecord::Migration
  def change
    add_column :users, :rating, :decimal
    add_column :users, :quantity_reviews, :integer

    add_column :venues, :rating, :decimal
    add_column :venues, :quantity_reviews, :integer
  end
end
