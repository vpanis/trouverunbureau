class NewMessageService < SimpleDelegator

  def send_notifications
    return unless user.settings['person_message'].present?
    notifiers.find(&:match?).notify
  end

  private

  def notifiers
    [CancelledMessageNotifier.new(self),
     PendingAuthorizationMessageNotifier.new(self),
     DefaultMessageNotifier.new(self)]
  end

  # While the ammount of notifiers stays small and the actions taken by the notifiers are few,
  # i'd rather keep them as inner classes
  # If the number of notifiers grows, we can extract them to a module and keep this class simple

  class CancelledMessageNotifier < SimpleDelegator
    def match?
      # TODO: Remove this "or". It should only be cancelled
      %w(cancelled denied refunded).any? { |a| m_type == a }
    end

    def notify
      NotificationsMailer.delay.host_cancellation_email(id)
    end
  end

  class PendingAuthorizationMessageNotifier < SimpleDelegator
    def match?
      m_type == 'pending_authorization'
    end

    def notify
      # let's not send an email for this action, it does not provide much information
    end
  end

  # keep this notifier as the last one in the notifiers array, since it will match on any message
  # type
  class DefaultMessageNotifier < SimpleDelegator
    def match?
      true
    end

    def notify
      NotificationsMailer.delay.new_message_email(id)
    end
  end
end
