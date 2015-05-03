class InquirySerializer < ActiveModel::Serializer
  include RepresentedHelper
  include ActionView::Helpers::DateHelper

  attributes :id, :space, :state, :from, :to, :b_type, :price, :quantity, :message_count,
             :last_message_at, :client, :fee, :deposit

  def space
    SpaceSerializer.new(object.space, only: [:id, :name, :city, :currency, :capacity, :venue_name,
                                             :logo],
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

  delegate :state, to: :object

  def last_message_at
    return time_ago_in_words(object.messages.last.created_at.to_s) if object.messages.last.present?
    time_ago_in_words(object.created_at)
  end

  def with_news
    BookingManager.booking_with_news?(object, current_represented) if current_represented
  end
end
