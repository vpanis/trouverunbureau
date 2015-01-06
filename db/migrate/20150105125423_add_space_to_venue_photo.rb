class AddSpaceToVenuePhoto < ActiveRecord::Migration
  def change
    add_reference :venue_photos, :space, index: true
  end
end
