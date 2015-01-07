# encoding: utf-8

class PhotoUploader < BaseUploader
  # Process files as they are uploaded:
  process resize_to_fit: [400, 500]

end
