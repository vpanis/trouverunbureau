class BraintreeVerifyReleasedJob
  @queue = :braintree_verify_released

  def self.perform(payment_id)
    @payment = BraintreePayment.find_by_id(payment_id)
    return unless @payment.present? # impossible, but...

    transaction = Braintree::Transaction.find(@payment.transaction_id).transaction
    if transaction.escrow_status == Braintree::Transaction::Status::ReleasePending
      Resque.enqueue_in(1.day, BraintreeVerifyReleasedJob, payment_id)
    elsif transaction.escrow_status == Braintree::Transaction::Status::Released
      @payment.update_attributes(escrow_status: transaction.escrow_status)
    else
      @payment.update_attributes(error_message: 'Can\'t verify if the escrow was released')
    end
  end
end
