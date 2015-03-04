class VenueReceiptSerializer < ActiveModel::Serializer
  attributes :id, :name, :street, :country, :town, :postal_code, :email, :phone, :currency, :logo

  def logo
    return nil unless object.logo
    object.logo.url
  end

end
