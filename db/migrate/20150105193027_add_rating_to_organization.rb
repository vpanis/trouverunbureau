class AddRatingToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :rating, :decimal
    add_column :organizations, :quantity_reviews, :integer
    add_column :organizations, :reviews_sum, :integer
  end
end
