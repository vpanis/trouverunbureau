class BraintreeEscrowAcceptedJob
  @queue = :braintree_escrow_accepted
  @escrow_polling_time = Rails.configuration.payment.braintree.time_to_poll_for_escrow_status

  def self.perform(booking_id, user_id)
    @booking = Booking.includes(:payment).find_by_id(booking_id)
    return unless @booking.present? && User.exists?(user_id) # impossible, but...

    transaction = braintree_transaction_find(@booking.payment.transaction_id)
    return accept_payment(transaction) if accepted_status?(transaction)
    not_accepted_payment(transaction)
  end

  private

  def braintree_transaction_find(transaction_id)
    Braintree::Transaction.find(transaction_id).transaction
  end

  def accept_payment(transaction)
    BookingManager.change_booking_status(User.find(user_id), @booking, Booking.states[:paid])
    @booking.payment.update_attributes(transaction_status: transaction.status,
                                       escrow_status: transaction.escrow_status)
  end

  def not_accepted_payment(transaction)
    attributes_to_update = { transaction_status: transaction.status,
                             escrow_status: transaction.escrow_status }
    if failed_status?(transaction)
      attributes_to_update[:error_message] = transaction.gateway_rejection_reason
    else
      Resque.enqueue_in(@escrow_polling_time, BraintreeEscrowAcceptedJob, @booking.id, user_id)
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
end
