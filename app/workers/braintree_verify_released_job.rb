class BraintreeVerifyReleasedJob
  @queue = :braintree_verify_released
  @v_release_polling_time = Rails.configuration.payment.braintree.hours_to_poll_for_verify_release

  class << self
    def perform(payment_id)
      init_log(payment_id)
      @payment = BraintreePayment.find_by_id(payment_id)
      return unless @payment.present? # impossible, but...

      transaction = Braintree::Transaction.find(@payment.transaction_id)
      verify_escrow_release(transaction)
    end

    private

    def init_log(payment_id)
      Rails.logger.info("BraintreeVerifyReleasedJob on payment_id: #{payment_id}")
    end

    def invalid_escrow_status_for_release_log(transaction)
      str = 'BraintreeVerifyReleasedJob invalid escrow status for verifing release on '
      str += "payment_id: #{@payment.id}, escrow_status: #{transaction.escrow_status}"
      Rails.logger.info(str)
    end

    def verify_escrow_release(transaction)
      if transaction.escrow_status == Braintree::Transaction::EscrowStatus::ReleasePending
        Resque.enqueue_in(@v_release_polling_time, BraintreeVerifyReleasedJob, @payment.id)
      elsif transaction.escrow_status == Braintree::Transaction::EscrowStatus::Released
        @payment.update_attributes(escrow_status: transaction.escrow_status)
      else
        invalid_escrow_status_for_release_log(transaction)
        @payment.update_attributes(error_message: 'Can\'t verify if the escrow was released')
      end
    end
  end
end
