class InquirySerializer < ActiveModel::Serializer
  include RepresentedHelper
  attributes :id, :space, :state, :from, :to, :price, :quantity, :message_count, :last_message_at

  # for some reason, it doesn't accept the 'only' used this way:
  # has_one :space, serializer: SpaceSerializer, only: [list]
  # so, for now, I've generated it manualy without the root to avoid
  # 'space:{ space: {'
  def space
    SpaceSerializer.new(object.space, only: [:id, :name, :city, :currency, :capacity], root: false)
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

  def last_message_at
    object.messages.last.created_at.to_s if object.messages.last.present?
  end

  def with_news
    BookingManager.booking_with_news?(object, current_represented) if current_represented
  end
end
