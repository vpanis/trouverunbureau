class RemoveVenuePhotoFromSpaces < ActiveRecord::Migration
  def change
  	remove_reference :spaces, :photo
  end
end
