class VenuePhoto < ActiveRecord::Base
	belongs_to :venue

	mount_uploader :photo, PhotoUploader

	before_destroy :erase_photo

	private
  		def erase_photo
  			self.remove_photo!
  		end
end
