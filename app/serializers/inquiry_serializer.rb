class InquirySerializer < ActiveModel::Serializer
  include RepresentedHelper
  attributes :id, :space, :state, :from, :to, :price, :quantity, :message_count, :last_message_at,
             :client

  def space
    SpaceSerializer.new(object.space, only: [:id, :name, :city, :currency, :capacity, :venue_name,
                                             :deposit, :logo],
                                      root: false)
  end

  def client
    ClientSerializer.new(object.owner, root: false)
  end

  def message_count
    object.messages.count
  end

  def from
    object.from.to_s
  end

  def to
    object.to.to_s
  end

  def state
    I18n.t("bookings.state.#{object.state}")
  end

  def last_message_at
    object.messages.last.created_at.to_s if object.messages.last.present?
  end

  def with_news
    BookingManager.booking_with_news?(object, current_represented) if current_represented
  end
end
