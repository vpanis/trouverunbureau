class CreateReviewVenues < ActiveRecord::Migration
  def change
    create_table :review_venues do |t|
      t.belongs_to :venue, index: true
      t.belongs_to :from_user, class_name: :user, index: true
      t.text :message
      t.integer :stars
      t.boolean :active

      t.timestamps
    end
  end
end
