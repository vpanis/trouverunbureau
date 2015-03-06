class BraintreeReleaseEscrowJob
  @queue = :braintree_release_escrow
  @escrow_polling_time = Rails.configuration.payment.braintree.time_to_poll_for_escrow_status

  class << self
    def perform(payment_id)
      @payment = BraintreePayment.find_by_id(payment_id)
      return unless @payment.present? # impossible, but...

      # Can't release a found if the transaction is not held
      if @payment.escrow_status == Braintree::Transaction::Status::Held
        release_from_escrow
      elsif @payment.escrow_status == Braintree::Transaction::Status::HoldPending
        # retries in 2 * the time waited to ask if the escrow is held or not
        Resque.enqueue_in(@escrow_polling_time * 2, BraintreeReleaseEscrowJob, payment_id)
      else
        @payment.update_attributes(error_message: 'Can\'t release escrow in this escrow_status')
      end
    end

    private

    def release_from_escrow
      release_result = Braintree::Transaction.release_from_escrow(@payment.transaction_id)
      # escrow_status = "release_pending"
      @payment.update_attributes(escrow_status: release_result.escrow_status)
      Resque.enqueue_in(1.days, BraintreeVerifyReleasedJob, @payment.id)
    end
  end
end
