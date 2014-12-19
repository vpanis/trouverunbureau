class AddVenuePhotoToSpace < ActiveRecord::Migration
  def change
  	add_reference :spaces, :photo, class_name: :venue_photo, index: true
  end
end
