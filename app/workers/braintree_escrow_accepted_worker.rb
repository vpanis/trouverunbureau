class BraintreeEscrowAcceptedWorker
  include Sidekiq::Worker

  def perform(booking_id, user_id)
    init_log(booking_id, user_id)
    @booking = Booking.includes(:payment).find_by_id(booking_id)
    return unless @booking.present? && User.exists?(user_id) # impossible, but...

    transaction = braintree_transaction_find(@booking.payment.transaction_id)
    return accept_payment(transaction, user_id) if accepted_status?(transaction)
    not_accepted_payment(transaction, user_id)
  end

  private

  def init_log(booking_id, user_id)
    str = "BraintreeEscrowAcceptedWorker on booking_id: #{booking_id}, user_id: #{user_id}"
    Rails.logger.info(str)
  end

  def not_accepted_payment_log(booking_id, transaction)
    str = "BraintreeEscrowAcceptedWorker not_accepted_payment for booking_id: #{booking_id}, "
    str += "transaction_id: #{transaction.id}, transaction_status: #{transaction.status}"
    Rails.logger.warn(str)
  end

  def braintree_transaction_find(transaction_id)
    Braintree::Transaction.find(transaction_id)
  end

  def accept_payment(transaction, user_id)
    BookingManager.change_booking_status(User.find(user_id), @booking, Booking.states[:paid])
    @booking.payment.update_attributes(transaction_status: transaction.status,
                                       escrow_status: transaction.escrow_status)
  end

  def not_accepted_payment(transaction, user_id)
    attributes_to_update = { transaction_status: transaction.status,
                             escrow_status: transaction.escrow_status }
    if failed_status?(transaction)
      not_accepted_payment_log(@booking.id, transaction)
      invalid_payment(attributes_to_update, transaction, user_id)
    else
      BraintreeEscrowAcceptedWorker.perform_in(escrow_polling_time, @booking.id, user_id)
    end
    @booking.payment.update_attributes(attributes_to_update)
  end

  def accepted_status?(transaction)
    transaction.status == Braintree::Transaction::Status::Settled &&
      transaction.escrow_status == Braintree::Transaction::EscrowStatus::Held
  end

  def failed_status?(transaction)
    transaction.status == Braintree::Transaction::Status::GatewayRejected &&
      transaction.status == Braintree::Transaction::Status::Failed
  end

  def escrow_polling_time
    Rails.configuration.payment.braintree.time_to_poll_for_escrow_status
  end

  def invalid_payment(attributes_to_update, transaction, user_id)
    attributes_to_update[:error_message] = transaction.gateway_rejection_reason
    BookingManager.change_booking_status(User.find(user_id), @booking,
                                         Booking.states[:pending_payment])
  end
end
