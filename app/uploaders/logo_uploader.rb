# encoding: utf-8

class LogoUploader < BaseUploader

  # Process files as they are uploaded:
  process resize_to_fit: [200, 200]

  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

end
