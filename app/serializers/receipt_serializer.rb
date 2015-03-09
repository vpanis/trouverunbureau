class ReceiptSerializer < ActiveModel::Serializer
  attributes :id, :created, :owner, :check_in, :days, :date, :check_out, :price, :quantity
  has_one :owner, serializer: UserReceiptSerializer
  has_one :space, serializer: SpaceReceiptSerializer
  has_one :venue, serializer: VenueReceiptSerializer

  def created
    object.booking.created_at.strftime('%a, %B %d, %Y')
  end

  def owner
    User.new(id: object.booking.owner.id, first_name: object.guest_first_name,
             last_name: object.guest_last_name, avatar: object.booking.owner.avatar,
             location: object.guest_location, email: object.guest_email, phone: object.guest_phone)
  end

  def space
    object.booking.space
  end

  def venue
    object.booking.space.venue
  end

  def quantity
    object.booking.quantity
  end

  def days
    return nil if object.booking.hour?
    (object.booking.to - object.booking.from).to_i / 1.day
  end

  def date
    return nil unless object.booking.hour?
    object.booking.from.strftime('%m/%d/%Y')
  end

  def check_in
    format = (object.booking.hour?) ? '%H:%M' : '%m/%d/%Y'
    object.booking.from.strftime(format)
  end

  def check_out
    format = (object.booking.hour?) ? '%H:%M' : '%m/%d/%Y'
    object.booking.to.strftime(format)
  end

  def price
    object.booking.price
  end

end
