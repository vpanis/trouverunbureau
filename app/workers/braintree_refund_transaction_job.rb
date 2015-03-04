class BraintreeRefundTransactionJob
  @queue = :braintree_refunds

  def self.perform(booking_id, user_id)
    @booking = Booking.includes(:payment).find_by_id(booking_id)
    return unless @booking.present? && User.exists?(user_id) # impossible, but...

    transaction = Braintree::Transaction.find(payment.transaction_id).transaction
    type = refund_or_void(transaction)
    if type.present?
      transaction_wrapper = Braintree::Transaction.send(type, payment.transaction_id)
      change_payment(transaction_wrapper)
    else
      no_refund_or_void_possible(transaction)
    end
  end

  private

  def change_payment(transaction_wrapper)
    attributes = { status: transaction_wrapper.transaction.status,
                   escrow_status: transaction_wrapper.transaction.escrow_status }
    if transaction_wrapper.success?
      status = Booking.states[:cancelled]
    else
      attributes[:error_message] = transaction_wrapper.errors
      status = Booking.states[:error_refunding]
    end
    @booking.payment.update_attributes(attributes)
    BookingManager.change_booking_status(User.find(user_id), @booking, status)
  end

  def refund_or_void(transaction)
    if transaction.status == Braintree::Transaction::Status::Settled ||
      transaction.status == Braintree::Transaction::Status::Settling
      'refund'
    elsif transaction.status == Braintree::Transaction::Status::SubmittedForSettlement ||
      transaction.status == Braintree::Transaction::Status::Authorized
      'void'
    else
      nil # The doc doesn't say anything about this case...
    end
  end

  def no_refund_or_void_possible(transaction)
    @booking.payment.update_attributes(status: transaction.status,
                                       escrow_status: transaction.escrow_status,
                                       error_message: 'Not a valid state for refund')
    BookingManager.change_booking_status(User.find(user_id), @booking,
                                         Booking.states[:error_refunding])
  end
end
