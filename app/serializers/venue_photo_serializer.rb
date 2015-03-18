class VenuePhotoSerializer < ActiveModel::Serializer
  attributes :id, :space_id, :venue_id, :photo

  def photo
    return nil unless object.photo
    object.photo.url
  end

end
