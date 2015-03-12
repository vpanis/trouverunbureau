class BraintreeRefundTransactionWorker
  include Sidekiq::Worker

  def perform(booking_id, user_id)
    init_log(booking_id, user_id)
    @booking = Booking.includes(:payment).find_by_id(booking_id)
    return unless @booking.present? && User.exists?(user_id) # impossible, but...

    transaction = Braintree::Transaction.find(@booking.payment.transaction_id).transaction
    return_money(transaction)
  end

  private

  def init_log(booking_id, user_id)
    str = "BraintreeRefundTransactionWorker on booking_id: #{booking_id}, user_id: #{user_id}"
    Rails.logger.info(str)
  end

  def not_refunded_log(booking_id, transaction)
    str = "BraintreeRefundTransactionWorker not refunded on booking_id: #{booking_id}, "
    str += "status: #{transaction.status}, escrow_status: #{transaction.escrow_status}"
    Rails.logger.warn(str)
  end

  def error_at_refund_log(booking_id, transaction_wrapper)
    str = "BraintreeRefundTransactionWorker error at refund on booking_id: #{booking_id}, "
    str += "status: #{transaction_wrapper.transaction.status}, escrow_status: "
    str += "#{transaction_wrapper.transaction.escrow_status}, "
    str += "error_message: #{transaction_wrapper.errors}"
    Rails.logger.warn(str)
  end

  def return_money(transaction)
    type = refund_or_void(transaction)
    if type.present?
      transaction_wrapper = Braintree::Transaction.send(type, @booking.payment.transaction_id)
      change_payment(transaction_wrapper)
    else
      no_refund_or_void_possible(transaction)
    end
  end

  def change_payment(transaction_wrapper)
    attributes = { status: transaction_wrapper.transaction.status,
                   escrow_status: transaction_wrapper.transaction.escrow_status }
    if transaction_wrapper.success?
      status = Booking.states[:cancelled]
    else
      error_at_refund(transaction_wrapper, attributes)
      status = Booking.states[:error_refunding]
    end
    @booking.payment.update_attributes(attributes)
    BookingManager.change_booking_status(User.find(user_id), @booking, status)
  end

  def error_at_refund(transaction_wrapper, attributes)
    error_at_refund_log(@booking.id, transaction_wrapper)
    attributes[:error_message] = transaction_wrapper.errors
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
    not_refunded_log(@booking.id, transaction)
    @booking.payment.update_attributes(status: transaction.status,
                                       escrow_status: transaction.escrow_status,
                                       error_message: 'Not a valid state for refund')
    BookingManager.change_booking_status(User.find(user_id), @booking,
                                         Booking.states[:error_refunding])
  end
end
