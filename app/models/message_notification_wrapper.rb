class MessageNotificationWrapper < SimpleDelegator

  def recipients_users
    @booking_w.recipients_users
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

end
