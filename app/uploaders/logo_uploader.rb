class LogoUploader < BaseUploader
  version :thumb do
    process resize_to_fit: [256, 256]
  end
end
