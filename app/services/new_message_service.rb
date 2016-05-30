class NewMessageService < SimpleDelegator
  def send_notifications
    notifiers.find(&:match?).notify
  end

  private

  def notifiers
    [
      CancelledMessageNotifier.new(self),
      DeniedMessageNotifier.new(self),
      PendingAuthorizationMessageNotifier.new(self),
      PendingPaymentMessageNotifier.new(self),
      InboxMessageNotifier.new(self),
      DefaultMessageNotifier.new(self)
    ]
  end

  # While the ammount of notifiers stays small and the actions taken by the notifiers are few,
  # i'd rather keep them as inner classes
  # If the number of notifiers grows, we can extract them to a module and keep this class simple

  class CancelledMessageNotifier < SimpleDelegator
    def match?
      m_type == 'cancelled'
    end

    def notify
      NotificationsMailer.delay.guest_cancellation_email(id, 'guest')
      NotificationsMailer.delay.guest_cancellation_email(id, 'host')
    end
  end

  class DeniedMessageNotifier < SimpleDelegator
    def match?
      %w(denied refunded).any? { |a| m_type == a }
    end

    def notify
      NotificationsMailer.delay.host_cancellation_email(id, 'host')
      NotificationsMailer.delay.host_cancellation_email(id, 'guest')
    end
  end

  class PendingAuthorizationMessageNotifier < SimpleDelegator
    def match?
      m_type == 'pending_authorization'
    end

    def notify
      # TODO: Replace with a 'Booking creation email'
      NotificationsMailer.delay.new_message_email(id, 'host')
    end
  end

  class PendingPaymentMessageNotifier < SimpleDelegator
    def match?
      m_type == 'pending_payment'
    end

    def notify
      NotificationsMailer.delay.new_message_email(id, 'guest')
    end
  end

  class InboxMessageNotifier < SimpleDelegator
    def match?
      m_type == 'text'
    end

    def notify
      NotificationsMailer.delay.new_message_email(id, destination_recipient)
    end
  end

  # keep this notifier as the last one in the notifiers array, since it will match on any message
  # type
  class DefaultMessageNotifier < SimpleDelegator
    def match?
      true
    end

    def notify
      NotificationsMailer.delay.new_message_email(id, 'host')
      NotificationsMailer.delay.new_message_email(id, 'guest')
    end
  end
end
