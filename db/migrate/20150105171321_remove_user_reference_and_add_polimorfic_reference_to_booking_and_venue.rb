class RemoveUserReferenceAndAddPolimorficReferenceToBookingAndVenue < ActiveRecord::Migration
  def change
  	remove_reference :venues, :owner
  	remove_reference :bookings, :user

  	add_reference :venues, :owner, polymorphic: true, index: true
  	add_reference :bookings, :owner, polymorphic: true, index: true
  end
end
