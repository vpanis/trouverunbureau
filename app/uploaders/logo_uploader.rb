class LogoUploader < BaseUploader
  # Process files as they are uploaded:
  process resize_to_fit: [256, 256]
end
