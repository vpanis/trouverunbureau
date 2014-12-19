# encoding: utf-8

class PhotoUploader < BaseUploader
  # Process files as they are uploaded:
  process :scale => [400, 500]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

end
