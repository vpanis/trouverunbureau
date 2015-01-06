# encoding: utf-8

class LogoUploader < BaseUploader

  # Process files as they are uploaded:
  process resize_to_fit: [200, 200]

end
