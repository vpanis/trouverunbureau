class PhotoUploader < BaseUploader
  version :thumb do
    process resize_to_fit: [400, 500]
  end
end
