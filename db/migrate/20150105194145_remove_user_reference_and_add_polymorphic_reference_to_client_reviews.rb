class RemoveUserReferenceAndAddPolymorphicReferenceToClientReviews < ActiveRecord::Migration
  def change
    remove_reference :client_reviews, :user
    add_reference :client_reviews, :client, polymorphic: true, index: true
  end
end
