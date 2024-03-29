class InquirySerializer < ActiveModel::Serializer
  include RepresentedHelper
  include ActionView::Helpers::DateHelper

  attributes :id, :space, :state, :from, :to, :b_type, :price, :quantity, :message_count,
             :last_message_at, :client, :deposit, :fee, :venue_owner, :with_news, :new

  def space
    SpaceSerializer.new(object.space, only: [:id, :name, :city, :country, :currency, :capacity, :venue_name,
                                             :logo, :currency_symbol, :guaranteed_months],
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

  def venue_owner
    object.space.venue.owner.eql?(scope)
  end

  def new
    return object.owner_last_seen.nil? if object.owner.eql?(scope)
    object.venue_last_seen.nil?
  end

  delegate :state, to: :object

  def last_message_at
    return time_ago_in_words(object.messages.last.created_at.to_s) if object.messages.last.present?
    time_ago_in_words(object.created_at)
  end

  def with_news
    BookingManager.booking_with_news?(object, scope) if scope
  end
end
