class MessageNotificationWrapper < SimpleDelegator

  def recipients_representees
    filter_representees_dont_want_messages(@booking_w.recipients_representees)
  end

  def recipient_owner
    @booking_w.owner == represented ? @booking_w.owner : @booking_w.space.venue.owner
  end

  def from
    represented.name
  end

  def message_text
    text || I18n.t("messages.#{m_type}")
  end

  private

  def initialize(message)
    super(message)
    @booking_w = BookingNotificationWrapper.new(booking)
  end

  def filter_representees_dont_want_messages(representees)
    representees_want_messages = []
    representees.each do |representee|
      user = representee
      user = representee.organization_users.first.user if representee.is_a?(Organization)
      representees_want_messages << representee if user.receives_person_message?
    end
    representees_want_messages
  end
end
